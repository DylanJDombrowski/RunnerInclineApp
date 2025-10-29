//
//  Segment.swift
//  RunnerInclineApp
//
//  Created by AI Assistant on 10/28/25.
//

import Foundation

struct Segment: Identifiable, Codable {
    let id: UUID
    let course_id: UUID
    let segment_index: Int
    let distance_miles: Double
    let elevation_ft: Double
    let grade_percent: Double?
    let created_at: Date
    let updated_at: Date
    
    /// Computed property for formatted grade
    var formattedGrade: String {
        guard let grade = grade_percent else { return "0.0%" }
        return String(format: "%.1f%%", grade)
    }
    
    /// Computed property for grade color based on steepness
    var gradeColorName: String {
        guard let grade = grade_percent else { return "MutedText" }
        switch grade {
        case ..<(-2): return "DownhillCyan"
        case -2..<0: return "DownhillCyan"
        case 0..<3: return "ActionGreen"
        case 3..<6: return "UphillOrange"
        default: return "UphillOrange"
        }
    }
}
