//
//  Course.swift
//  RunnerInclineApp
//
//  Created by Dylan Dombrowski on 10/18/25.
//

import Foundation

struct Course: Identifiable, Codable {
    let id: UUID
    let name: String
    let city: String?
    let distance_miles: Double?
    let total_elevation_gain_ft: Double?
    let gpx_url: String?
    let source_type: String?
    let source_link: String?
    let verified: Bool
    let created_at: String?
    let created_by: UUID?  // New field for user ownership
}
