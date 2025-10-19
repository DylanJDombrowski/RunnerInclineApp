//
//  CourseListView.swift
//  RunnerInclineApp
//
//  Created by Dylan Dombrowski on 10/18/25.
//

import SwiftUI

struct CourseListView: View {
    @StateObject var vm = CourseViewModel()
    
    var body: some View {
        NavigationView {
            List(vm.courses) { course in
                VStack(alignment: .leading) {
                    Text(course.name).font(.headline)
                    if let city = course.city {
                        Text(city).font(.subheadline).foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Courses")
            .onAppear { vm.fetchCourses() }
        }
    }
}

#Preview {
    CourseListView()
}
