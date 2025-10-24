//
//  Segment.swift
//  RunnerInclineApp
//
//  Created by Dylan Dombrowski on 10/19/25.
//

import Foundation

struct Segment: Identifiable, Codable {
    let id: UUID
    let course_id: UUID
    let segment_index: Int
    let distance_miles: Double
    let elevation_ft: Double
    let grade_percent: Double?
    let created_at: String?
}
