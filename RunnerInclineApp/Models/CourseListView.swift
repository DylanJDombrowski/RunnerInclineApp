//
//  CourseListView.swift
//  RunnerInclineApp
//
//  Created by Dylan Dombrowski on 10/18/25.
//

import SwiftUI

struct CourseListView: View {
    @StateObject var vm = CourseViewModel()
    @State private var showingUpload = false

    var body: some View {
        NavigationStack {
            List(vm.courses) { course in
                NavigationLink(destination: CourseDetailView(course: course)) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(course.name).font(.headline)
                            Spacer()
                            if course.verified {
                                Image(systemName: "checkmark.shield")
                                    .foregroundColor(.green)
                                    .font(.caption)
                            }
                        }
                        if let city = course.city {
                            Text(city).font(.subheadline).foregroundColor(.secondary)
                        }
                        if let distance = course.distance_miles {
                            Text("\(distance, specifier: "%.1f") miles")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Marathon Courses")
//            .toolbar {
//                ToolbarItem(placement: .primaryAction) {
//                    Button(action: { showingUpload = true }) {
//                        Image(systemName: "plus")
//                    }
//                }
//            }
            .refreshable {
                vm.fetchCourses()
            }
            .onAppear { vm.fetchCourses() }
            .sheet(isPresented: $showingUpload) {
                GPXUploadView()
                    .onDisappear {
                        // Refresh courses after upload
                        vm.fetchCourses()
                    }
            }
        }
    }
}

