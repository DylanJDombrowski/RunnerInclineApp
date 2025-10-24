//
//  MyCoursesView.swift
//  RunnerInclineApp
//
//  Created by Assistant on 10/23/25.
//

import SwiftUI

struct MyCoursesView: View {
    @StateObject private var viewModel = CourseViewModel()
    @StateObject private var authManager = AuthenticationManager.shared
    @State private var showingUpload = false
    
    var body: some View {
        NavigationStack {
            Group {
                if !authManager.isAuthenticated {
                    // Not signed in state
                    ContentUnavailableView {
                        Label("Sign In Required", systemImage: "person.circle")
                    } description: {
                        Text("Sign in to upload and manage your courses")
                    } actions: {
                        NavigationLink(destination: AuthenticationView()) {
                            Text("Sign In")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                    
                } else if userCourses.isEmpty {
                    // No courses state
                    ContentUnavailableView {
                        Label("No Courses Yet", systemImage: "map")
                    } description: {
                        Text("Upload your first GPX file to get started")
                    } actions: {
                        Button {
                            showingUpload = true
                        } label: {
                            Text("Upload Course")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                    
                } else {
                    // Courses list
                    List(userCourses) { course in
                        NavigationLink(destination: CourseDetailView(course: course)) {
                            CourseRowView(course: course)
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                    .listStyle(.plain)
                    .refreshable {
                        viewModel.loadCourses()
                    }
                }
            }
            .navigationTitle("My Courses")
            .toolbar {
                if authManager.isAuthenticated {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showingUpload = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingUpload) {
                NavigationStack {
                    GPXUploadView()
                }
            }
            .onAppear {
                viewModel.loadCourses()
            }
        }
    }
    
    private var userCourses: [Course] {
        guard let userId = authManager.currentUser?.id else { return [] }
        return viewModel.courses.filter { $0.created_by == userId }
    }
}

struct CourseRowView: View {
    let course: Course
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(course.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Spacer()
                
                // Status badge
                Group {
                    if course.verified {
                        Label("Verified", systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.2))
                            .foregroundColor(.green)
                            .cornerRadius(6)
                    } else {
                        Label("Pending", systemImage: "clock")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange.opacity(0.2))
                            .foregroundColor(.orange)
                            .cornerRadius(6)
                    }
                }
            }
            
            if let city = course.city {
                Text(city)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                if let distance = course.distance_miles {
                    Label("\(distance, specifier: "%.1f") mi", systemImage: "ruler")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let elevation = course.total_elevation_gain_ft {
                    Label("\(Int(elevation)) ft", systemImage: "mountain.2")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if let createdAt = course.created_at {
                    Text(formatDate(createdAt))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .short
            return displayFormatter.string(from: date)
        }
        return ""
    }
}

#Preview {
    MyCoursesView()
}