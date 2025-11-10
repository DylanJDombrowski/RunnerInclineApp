//
//  MyCoursesView.swift
//  RunnerInclineApp
//
//  Created by Assistant on 10/23/25.
//

import Auth
import Supabase
import SwiftUI

struct MyCoursesView: View {
    @StateObject private var viewModel = CourseViewModel()
    @StateObject private var authManager = AuthenticationManager.shared
    @State private var showingUpload = false

    var body: some View {
        NavigationStack {
            if !authManager.isAuthenticated {
                // Not signed in state
                VStack(spacing: 20) {
                    Image(systemName: "person.circle")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)

                    Text("Sign In Required")
                        .font(.headline)

                    Text("Sign in to upload and manage your courses")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)

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
                .padding()

            } else if userCourses.isEmpty {
                // NEW "My Library" empty state
                VStack(spacing: 20) {
                    Image(systemName: "star.fill")  // Or "bookmark.fill"
                        .font(.system(size: 60))
                        .foregroundColor(.gray)

                    Text("Your Library is Empty")
                        .font(.headline)

                    Text(
                        "Courses you purchase or add to your library will appear here."
                    )
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)

                    // The upload button has been removed.
                }
                .padding()

            } else {
                // Courses list
                List(userCourses) { course in
                    NavigationLink(
                        destination: CourseDetailView(course: course)
                    ) {
                        CourseRowView(course: course)
                    }
                    .listRowInsets(
                        EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
                    )
                }
                .listStyle(.plain)
                .refreshable {
                    viewModel.fetchCourses()
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
            viewModel.fetchCourses()
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
                    Label(
                        "\(distance, specifier: "%.1f") mi",
                        systemImage: "ruler"
                    )
                    .font(.caption)
                    .foregroundColor(.secondary)
                }

                if let elevation = course.total_elevation_gain_ft {
                    Label("\(Int(elevation)) ft", systemImage: "mountain.2")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text(formatDate(course.created_at))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private func formatDate(_ date: Date) -> String {
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .short
        return displayFormatter.string(from: date)
    }
}

#Preview {
    MyCoursesView()
}
