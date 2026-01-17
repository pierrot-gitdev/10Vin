//
//  LoginView.swift
//  10Vin
//
//  Created by Pierre ROBERT on 16/01/2026.
//

import SwiftUI
import GoogleSignIn

struct LoginView: View {
    @EnvironmentObject var authService: FirebaseAuthService
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var isSignUp = false
    @State private var showError = false
    
    var body: some View {
        ZStack {
            WineTheme.cream
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Logo/Titre
                    VStack(spacing: 16) {
                        Image(systemName: "wineglass.fill")
                            .font(.system(size: 80))
                            .foregroundColor(WineTheme.burgundy)
                        
                        Text("10Vin")
                            .font(WineTheme.titleFont)
                            .foregroundColor(WineTheme.burgundy)
                        
                        Text(isSignUp ? "auth.createAccount".localized : "auth.welcome".localized)
                            .font(.subheadline)
                            .foregroundColor(WineTheme.darkGray)
                    }
                    .padding(.top, 60)
                    
                    // Formulaire
                    VStack(spacing: 20) {
                        if isSignUp {
                            // Username (uniquement pour l'inscription)
                            VStack(alignment: .leading, spacing: 8) {
                                Text("auth.username".localized)
                                    .font(.headline)
                                    .foregroundColor(WineTheme.burgundy)
                                
                                TextField("auth.username.placeholder".localized, text: $username)
                                    .textFieldStyle(.roundedBorder)
                                    .autocapitalization(.none)
                            }
                        }
                        
                        // Email
                        VStack(alignment: .leading, spacing: 8) {
                            Text("auth.email".localized)
                                .font(.headline)
                                .foregroundColor(WineTheme.burgundy)
                            
                            TextField("auth.email.placeholder".localized, text: $email)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                        }
                        
                        // Password
                        VStack(alignment: .leading, spacing: 8) {
                            Text("auth.password".localized)
                                .font(.headline)
                                .foregroundColor(WineTheme.burgundy)
                            
                            SecureField("auth.password.placeholder".localized, text: $password)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        // Bouton principal
                        Button(action: {
                            Task {
                                await handleAuth()
                            }
                        }) {
                            HStack {
                                if authService.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text(isSignUp ? "auth.signUp".localized : "auth.signIn".localized)
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(WineTheme.burgundy)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(authService.isLoading || !isFormValid)
                        .opacity(isFormValid ? 1 : 0.6)
                        
                        // Divider
                        HStack {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 1)
                            Text("auth.or".localized)
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 1)
                        }
                        
                        // Google Sign In
                        Button(action: {
                            Task {
                                await handleGoogleSignIn()
                            }
                        }) {
                            HStack {
                                Image(systemName: "globe")
                                Text("auth.signInWithGoogle".localized)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(WineTheme.darkGray)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .disabled(authService.isLoading)
                    }
                    .padding(.horizontal, 32)
                    
                    // Toggle Sign Up / Sign In
                    Button(action: {
                        withAnimation {
                            isSignUp.toggle()
                        }
                    }) {
                        HStack {
                            Text(isSignUp ? "auth.alreadyHaveAccount".localized : "auth.noAccount".localized)
                                .foregroundColor(WineTheme.darkGray)
                            Text(isSignUp ? "auth.signIn".localized : "auth.signUp".localized)
                                .foregroundColor(WineTheme.burgundy)
                                .fontWeight(.semibold)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .alert("common.error".localized, isPresented: $showError) {
            Button("common.ok".localized, role: .cancel) { }
        } message: {
            Text(authService.errorMessage ?? "auth.error.unknown".localized)
        }
    }
    
    private var isFormValid: Bool {
        if isSignUp {
            return !email.isEmpty && !password.isEmpty && !username.isEmpty && password.count >= 6
        } else {
            return !email.isEmpty && !password.isEmpty
        }
    }
    
    private func handleAuth() async {
        do {
            if isSignUp {
                try await authService.signUp(email: email, password: password, username: username)
            } else {
                try await authService.signIn(email: email, password: password)
            }
        } catch {
            showError = true
        }
    }
    
    private func handleGoogleSignIn() async {
        do {
            try await authService.signInWithGoogle()
        } catch {
            showError = true
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(FirebaseAuthService())
}
