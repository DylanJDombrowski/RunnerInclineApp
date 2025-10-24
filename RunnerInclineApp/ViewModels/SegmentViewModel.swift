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
    @Published var isLoading = false
    
    func fetchSegments(for courseID: UUID) {
        isLoading = true
        Task {
            do {
                let response: [Segment] = try await SupabaseService.shared.client
                    .from("segments")
                    .select()
                    .eq("course_id", value: courseID)
                    .order("segment_index", ascending: true)
                    .execute()
                    .value
                self.segments = response
                print("✅ Loaded \(response.count) segments for course \(courseID)")
            } catch {
                print("❌ Error loading segments:", error.localizedDescription)
                self.segments = []
            }
            isLoading = false
        }
    }
    
    func refreshSegments(for courseID: UUID) {
        fetchSegments(for: courseID)
    }
}
