//
//  CourseViewModel.swift
//  RunnerInclineApp
//
//  Created by Dylan Dombrowski on 10/18/25.
//

import Foundation
import Combine
import Supabase

@MainActor
final class CourseViewModel: ObservableObject {
    @Published var courses: [Course] = []
    
    func fetchCourses() {
        Task {
            do {
                let response: [Course] = try await SupabaseService.shared.client
                    .database
                    .from("courses")
                    .select()
                    .execute()
                    .value
                self.courses = response
                print("✅ Supabase connected — \(response.count) courses loaded.")
            } catch {
                print("❌ Supabase fetch error:", error.localizedDescription)
            }
        }
    }
}
