//
//  AuthenticationView.swift
//  RunnerInclineApp
//
//  Created by Dylan Dombrowski on 10/20/25.
//

import SwiftUI
import AuthenticationServices

struct AuthenticationView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                // App branding
                VStack(spacing: 16) {
                    Image(systemName: "figure.run")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Runner Incline")
                        .font(.largeTitle.bold())
                    
                    Text("Upload and share marathon elevation profiles")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                // Authentication section
                VStack(spacing: 20) {
                    Text("Sign in to upload courses")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    if authManager.isLoading {
                        ProgressView("Signing in...")
                    } else {
                        SignInWithAppleButton(.signIn) { request in
                            request.requestedScopes = [.email]
                        } onCompletion: { result in
                            Task {
                                await handleSignInWithApple(result)
                            }
                        }
                        .frame(height: 50)
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
                
                // Skip option for browsing
                Button("Browse courses without signing in") {
                    dismiss()
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding()
            .navigationTitle("Welcome")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .onChange(of: authManager.isAuthenticated) { _, isAuthenticated in
            if isAuthenticated {
                dismiss()
            }
        }
    }
    
    private func handleSignInWithApple(_ result: Result<ASAuthorization, Error>) async {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                do {
                    try await authManager.signInWithApple(credential: appleIDCredential)
                } catch {
                    print("❌ Authentication failed: \(error.localizedDescription)")
                    // Could show an alert here if needed
                }
            }
        case .failure(let error):
            // Handle Apple ID authorization errors
            let nsError = error as NSError
            if nsError.domain == "com.apple.AuthenticationServices.AuthorizationError" {
                switch nsError.code {
                case 1000:
                    print("ℹ️ User canceled Apple ID sign in")
                    // This is normal - user tapped "Cancel", no need for error message
                case 1001:
                    print("❌ Apple ID sign in failed: Unknown error")
                case 1004:
                    print("❌ Apple ID sign in failed: Not handled")
                default:
                    print("❌ Apple ID authorization error: \(error.localizedDescription)")
                }
            } else {
                print("❌ Sign in error: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    AuthenticationView()
        .environmentObject(AuthenticationManager())
}