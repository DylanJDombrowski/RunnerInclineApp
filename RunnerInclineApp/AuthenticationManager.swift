//
//  AuthenticationManager.swift
//  RunnerInclineApp
//
//  Created by Dylan Dombrowski on 10/20/25.
//

import Foundation
import Supabase
import AuthenticationServices
import SwiftUI

@MainActor
final class AuthenticationManager: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    
    private let supabase = SupabaseService.shared.client
    
    init() {
        // Check if user is already signed in
        Task {
            await checkCurrentUser()
        }
    }
    
    func checkCurrentUser() async {
        isLoading = true
        do {
            user = try await supabase.auth.user()
            isAuthenticated = user != nil
        } catch {
            print("❌ Auth check failed: \(error)")
            isAuthenticated = false
            user = nil
        }
        isLoading = false
    }
    
    func signInWithApple(credential: ASAuthorizationAppleIDCredential) async throws {
        guard let identityToken = credential.identityToken,
              let identityTokenString = String(data: identityToken, encoding: .utf8) else {
            throw AuthError.invalidCredentials
        }
        
        isLoading = true
        
        do {
            let session = try await supabase.auth.signInWithIdToken(
                credentials: .init(
                    provider: .apple,
                    idToken: identityTokenString
                )
            )
            
            self.user = session.user
            self.isAuthenticated = true
            
        } catch {
            print("❌ Sign in with Apple failed: \(error)")
            throw error
        }
        
        isLoading = false
    }
    
    func signOut() async {
        isLoading = true
        
        do {
            try await supabase.auth.signOut()
            self.user = nil
            self.isAuthenticated = false
        } catch {
            print("❌ Sign out failed: \(error)")
        }
        
        isLoading = false
    }
}

enum AuthError: LocalizedError {
    case invalidCredentials
    case signInFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid Apple ID credentials"
        case .signInFailed:
            return "Sign in failed. Please try again."
        }
    }
}