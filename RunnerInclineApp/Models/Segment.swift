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
    let mile_start: Double
    let mile_end: Double
    let incline_percent: Double
    let elevation_ft: Double?
    let grade_direction: String?
}
