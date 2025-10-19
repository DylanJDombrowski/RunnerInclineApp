//
//  SegmentViewModel.swift
//  RunnerInclineApp
//
//  Created by Dylan Dombrowski on 10/19/25.
//

import Foundation
import Combine
import Supabase


@MainActor
final class SegmentViewModel: ObservableObject {
    @Published var segments: [Segment] = []
    
    func fetchSegments(for courseID: UUID) {
        Task {
            do {
                let response: [Segment] = try await SupabaseService.shared.client
                    .database
                    .from("segments")
                    .select()
                    .eq("course_id", value: courseID)
                    .order("mile_start", ascending: true)
                    .execute()
                    .value
                self.segments = response
                print("✅ Loaded \(response.count) segments for course \(courseID)")
            } catch {
                print("❌ Error loading segments:", error.localizedDescription)
            }
        }
    }
}
