//
//  MainTabView.swift
//  RunnerInclineApp
//
//  Created by Assistant on 10/23/25.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var authManager = AuthenticationManager.shared
    
    var body: some View {
        TabView {
            // Home Tab
            NavigationStack {
                CourseListView()
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            
            // My Courses Tab
            NavigationStack {
                MyCoursesView()
            }
            .tabItem {
                Image(systemName: "map.fill")
                Text("My Courses")
            }
            
            // Profile Tab
            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Image(systemName: "person.circle.fill")
                Text("Profile")
            }
        }
        .onAppear {
            // Check authentication status when app appears
            Task {
                await authManager.checkAuthStatus()
            }
        }
    }
}

#Preview {
    MainTabView()
}