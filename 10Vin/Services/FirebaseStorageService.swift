//
//  FirebaseStorageService.swift
//  10Vin
//
//  Created by Pierre ROBERT on 24/01/2026.
//

import Foundation
import FirebaseStorage
import FirebaseAuth
import UIKit

class FirebaseStorageService {
    private let storage = Storage.storage()
    
    /// Upload une image et retourne l'URL de téléchargement
    func uploadImage(_ image: UIImage, path: String) async throws -> String {
        // Vérifier que l'utilisateur est authentifié
        guard Auth.auth().currentUser != nil else {
            throw StorageError.userNotAuthenticated
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw StorageError.imageConversionFailed
        }
        
        let storageRef = storage.reference().child(path)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        // Upload l'image
        _ = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<StorageMetadata, Error>) in
            storageRef.putData(imageData, metadata: metadata) { metadata, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let metadata = metadata {
                    continuation.resume(returning: metadata)
                } else {
                    continuation.resume(throwing: StorageError.uploadFailed)
                }
            }
        }
        
        // Récupérer l'URL de téléchargement
        let downloadURL = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<URL, Error>) in
            storageRef.downloadURL { url, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let url = url {
                    continuation.resume(returning: url)
                } else {
                    continuation.resume(throwing: StorageError.downloadFailed)
                }
            }
        }
        
        return downloadURL.absoluteString
    }
    
    /// Upload une image de vin
    func uploadWineImage(_ image: UIImage, wineId: String) async throws -> String {
        let path = "wines/\(wineId)/photo.jpg"
        return try await uploadImage(image, path: path)
    }
    
    /// Supprime une image
    func deleteImage(at path: String) async throws {
        let storageRef = storage.reference().child(path)
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            storageRef.delete { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
}

enum StorageError: LocalizedError {
    case imageConversionFailed
    case uploadFailed
    case downloadFailed
    case userNotAuthenticated
    
    var errorDescription: String? {
        switch self {
        case .imageConversionFailed:
            return "Failed to convert image to data"
        case .uploadFailed:
            return "Failed to upload image"
        case .downloadFailed:
            return "Failed to download image"
        case .userNotAuthenticated:
            return "User is not authenticated. Please sign in to upload images."
        }
    }
}
