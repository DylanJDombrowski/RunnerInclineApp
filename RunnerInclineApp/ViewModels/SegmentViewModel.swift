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
        print("🔍 DEBUG: Fetching segments for course: \(courseID)")
        Task {
            do {
                // First, test basic connection with minimal fields
                print("🔍 DEBUG: Testing basic segment query...")
                let basicResponse = try await SupabaseService.shared.client
                    .from("segments")
                    .select("id, course_id, segment_index")
                    .eq("course_id", value: courseID)
                    .execute()
                
                print("🔍 DEBUG: Basic query response: \(basicResponse)")
                
                // Now try full query
                print("🔍 DEBUG: Testing full segment query...")
                let response: [Segment] = try await SupabaseService.shared.client
                    .from("segments")
                    .select()
                    .eq("course_id", value: courseID)
                    .order("segment_index", ascending: true)
                    .execute()
                    .value
                
                self.segments = response
                print("✅ DEBUG: Successfully loaded \(response.count) segments")
                
            } catch {
                print("❌ DEBUG: Detailed error info:")
                print("❌ Error type: \(type(of: error))")
                print("❌ Error description: \(error)")
                print("❌ Localized: \(error.localizedDescription)")
                
                // Check for decoding errors
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .keyNotFound(let key, let context):
                        print("❌ Missing key: \(key.stringValue)")
                        print("❌ Context: \(context)")
                    case .typeMismatch(let type, let context):
                        print("❌ Type mismatch for: \(type)")  
                        print("❌ Context: \(context)")
                    case .valueNotFound(let type, let context):
                        print("❌ Value not found for: \(type)")
                        print("❌ Context: \(context)")
                    case .dataCorrupted(let context):
                        print("❌ Data corrupted: \(context)")
                    @unknown default:
                        print("❌ Unknown decoding error")
                    }
                }
                
                self.segments = []
            }
            isLoading = false
        }
    }
    
    func refreshSegments(for courseID: UUID) {
        fetchSegments(for: courseID)
    }
}
