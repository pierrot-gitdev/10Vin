//
//  FirebaseAuthService.swift
//  10Vin
//
//  Created by Pierre ROBERT on 16/01/2026.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import UIKit

@MainActor
class FirebaseAuthService: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let firestoreService = FirestoreService()
    
    init() {
        // Vérifier l'état initial d'authentification
        checkAuthState()
        
        // Observer les changements d'authentification
        Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            Task { @MainActor in
                if let firebaseUser = firebaseUser {
                    await self?.loadUserData(userId: firebaseUser.uid)
                    self?.isAuthenticated = true
                } else {
                    self?.currentUser = nil
                    self?.isAuthenticated = false
                }
            }
        }
    }
    
    private func checkAuthState() {
        Task { @MainActor in
            if let firebaseUser = Auth.auth().currentUser {
                await loadUserData(userId: firebaseUser.uid)
                isAuthenticated = true
            } else {
                currentUser = nil
                isAuthenticated = false
            }
        }
    }
    
    // MARK: - Email/Password Authentication
    
    func signUp(email: String, password: String, username: String) async throws {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        do {
            // Créer l'utilisateur dans Firebase Auth
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            
            // Créer le profil utilisateur dans Firestore
            let newUser = User(
                id: result.user.uid,
                username: username,
                email: email,
                profileImageURL: nil,
                winesTasted: [],
                wishlist: [],
                following: [],
                followers: [],
                privacyLevel: .public
            )
            
            try await firestoreService.createUser(newUser)
            self.currentUser = newUser
            self.isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    func signIn(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            await loadUserData(userId: result.user.uid)
            self.isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    // MARK: - Google Sign In
    
    func signInWithGoogle() async throws {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        // Récupérer le CLIENT_ID depuis FirebaseApp
        // Pour Google Sign In, le CLIENT_ID est généralement dans FirebaseApp.options.clientID
        // Si ce n'est pas disponible, il faut le récupérer depuis Firebase Console
        
        guard let firebaseApp = FirebaseApp.app(),
              let clientID = firebaseApp.options.clientID else {
            throw AuthError.missingClientID
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let presentingViewController = getRootViewController() else {
            throw AuthError.missingRootViewController
        }
        
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController)
            guard let idToken = result.user.idToken?.tokenString else {
                throw AuthError.missingIDToken
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: result.user.accessToken.tokenString)
            
            let authResult = try await Auth.auth().signIn(with: credential)
            
            // Vérifier si l'utilisateur existe déjà dans Firestore
            if let existingUser = try? await firestoreService.getUser(userId: authResult.user.uid) {
                self.currentUser = existingUser
            } else {
                // Créer un nouvel utilisateur
                let newUser = User(
                    id: authResult.user.uid,
                    username: authResult.user.displayName ?? "User",
                    email: authResult.user.email ?? "",
                    profileImageURL: authResult.user.photoURL?.absoluteString,
                    winesTasted: [],
                    wishlist: [],
                    following: [],
                    followers: [],
                    privacyLevel: .public
                )
                
                try await firestoreService.createUser(newUser)
                self.currentUser = newUser
            }
            
            self.isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    @MainActor
    private func getRootViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            return nil
        }
        return rootViewController
    }
    
    // MARK: - Sign Out
    
    func signOut() throws {
        try Auth.auth().signOut()
        try? GIDSignIn.sharedInstance.signOut()
        // Le listener va automatiquement mettre à jour isAuthenticated à false
        // Mais on le fait aussi manuellement pour être sûr
        self.currentUser = nil
        self.isAuthenticated = false
    }
    
    // MARK: - Load User Data
    
    private func loadUserData(userId: String) async {
        do {
            if let user = try await firestoreService.getUser(userId: userId) {
                self.currentUser = user
            }
        } catch {
            print("Error loading user data: \(error.localizedDescription)")
            // Erreur silencieuse lors du chargement des données utilisateur
        }
    }
    
    // MARK: - Update User
    
    func updateUser(_ user: User) async throws {
        try await firestoreService.updateUser(user)
        self.currentUser = user
    }
}

// MARK: - Auth Errors

enum AuthError: LocalizedError {
    case missingClientID
    case missingRootViewController
    case missingIDToken
    
    var errorDescription: String? {
        switch self {
        case .missingClientID:
            return "Firebase Client ID is missing"
        case .missingRootViewController:
            return "Root view controller is missing"
        case .missingIDToken:
            return "Google ID token is missing"
        }
    }
}
