//
//  PaceSegment.swift
//  RunnerInclineApp
//
//  Created by AI Assistant on 10/28/25.
//

import Foundation

struct PaceSegment: Identifiable, Codable {
    let id: UUID
    let course_id: UUID
    let segment_index: Int
    let distance_miles: Double
    let recommended_pace_seconds_per_mile: Int
    let created_at: Date
    let updated_at: Date
    
    /// Computed property to get pace as MM:SS format
    var formattedPace: String {
        let minutes = recommended_pace_seconds_per_mile / 60
        let seconds = recommended_pace_seconds_per_mile % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    /// Computed property to get pace in decimal minutes (e.g., 6.87 for 6:52)
    var paceMinutes: Double {
        return Double(recommended_pace_seconds_per_mile) / 60.0
    }
}