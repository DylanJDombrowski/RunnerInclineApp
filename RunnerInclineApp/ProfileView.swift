//
//  ProfileView.swift
//  RunnerInclineApp
//
//  Created by Assistant on 10/23/25.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var authManager = AuthenticationManager.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if authManager.isAuthenticated {
                    // Authenticated State
                    VStack(spacing: 16) {
                        // User info
                        VStack(spacing: 8) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)
                            
                            if let user = authManager.currentUser {
                                Text(user.email ?? "Unknown User")
                                    .font(.headline)
                                Text("ID: \(user.id.uuidString.prefix(8))...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Divider()
                        
                        // Actions
                        VStack(spacing: 12) {
                            NavigationLink(destination: MyCourses()) {
                                HStack {
                                    Image(systemName: "map")
                                    Text("My Uploaded Courses")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                            }
                            
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
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                    
                } else {
                    // Not Authenticated State
                    VStack(spacing: 16) {
                        Image(systemName: "person.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("Not Signed In")
                            .font(.headline)
                        
                        Text("Sign in to upload courses and track your progress")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            Task {
                                await authManager.signInWithApple()
                            }
                        }) {
                            HStack {
                                Image(systemName: "applelogo")
                                Text("Sign in with Apple")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                }
                
                Spacer()
            }
            .navigationTitle("Profile")
        }
    }
}

// Simple view for user's courses
struct MyCourses: View {
    @StateObject private var viewModel = CourseViewModel()
    @StateObject private var authManager = AuthenticationManager.shared
    
    var body: some View {
        List {
            if viewModel.courses.isEmpty {
                Text("No courses uploaded yet")
                    .foregroundColor(.secondary)
            } else {
                ForEach(userCourses) { course in
                    NavigationLink(destination: CourseDetailView(course: course)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(course.name)
                                .font(.headline)
                            
                            if let city = course.city {
                                Text(city)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack {
                                if course.verified {
                                    Label("Verified", systemImage: "checkmark.circle.fill")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                } else {
                                    Label("Pending Review", systemImage: "clock")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                }
                                
                                Spacer()
                                
                                if let distance = course.distance_miles {
                                    Text("\(distance, specifier: "%.1f") mi")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle("My Courses")
        .onAppear {
            viewModel.loadCourses()
        }
    }
    
    private var userCourses: [Course] {
        guard let userId = authManager.currentUser?.id else { return [] }
        return viewModel.courses.filter { $0.created_by == userId }
    }
}

#Preview {
    ProfileView()
}