//
//  ProfileView.swift
//  RunnerInclineApp
//
//  Created by Assistant on 10/23/25.
//

import SwiftUI
import Auth
import Supabase

struct ProfileView: View {
    @StateObject private var authManager = AuthenticationManager.shared
    @State private var showingAuth = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if authManager.isAuthenticated {
                    // Authenticated State
                    VStack(spacing: 20) {
                        // User avatar section
                        VStack(spacing: 12) {
                            Circle()
                                .fill(Color.blue.gradient)
                                .frame(width: 80, height: 80)
                                .overlay {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 36))
                                        .foregroundColor(.white)
                                }
                            
                            VStack(spacing: 4) {
                                if let user = authManager.currentUser {
                                    Text(user.email ?? "Unknown User")
                                        .font(.headline)
                                    Text("User ID: \(user.id.uuidString.prefix(8))...")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        // Quick stats card
                        VStack(spacing: 16) {
                            Text("Account Details")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 12) {
                                InfoRow(icon: "applelogo", title: "Sign-in Method", value: "Apple ID")
                                InfoRow(icon: "calendar", title: "Member Since", value: "Today") // Could be calculated from user.created_at
                                InfoRow(icon: "checkmark.shield", title: "Status", value: "Verified")
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        // Sign out button
                        Button(action: {
                            Task {
                                await authManager.signOut()
                            }
                        }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Sign Out")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .foregroundColor(.red)
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                    
                } else {
                    // Not Authenticated State
                    ContentUnavailableView {
                        Label("Welcome to Runner Incline", systemImage: "figure.run")
                    } description: {
                        Text("Sign in to upload courses, track your progress, and join the community")
                    } actions: {
                        Button {
                            showingAuth = true
                        } label: {
                            HStack {
                                Image(systemName: "applelogo")
                                Text("Sign in with Apple")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showingAuth) {
                AuthenticationView()
            }
        }
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(title)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }
}

#Preview {
    ProfileView()
}