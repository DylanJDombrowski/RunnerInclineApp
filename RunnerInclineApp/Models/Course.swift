//
//  Course.swift
//  RunnerInclineApp
//
//  Created by AI Assistant on 10/28/25.
//

import Foundation

struct Course: Identifiable, Codable {
    let id: UUID
    let name: String
    let city: String?
    let distance_miles: Double?
    let total_elevation_gain_ft: Double?
    let gpx_url: String?
    let verified: Bool
    let created_by: UUID?
    let created_at: Date
    let updated_at: Date
    
    /// Computed property for display name
    var displayName: String {
        if let city = city {
            return "\(name), \(city)"
        }
        return name
    }
    
    /// Computed property for formatted distance
    var formattedDistance: String {
        guard let distance = distance_miles else { return "Unknown" }
        return String(format: "%.1f mi", distance)
    }
    
    /// Computed property for formatted elevation
    var formattedElevation: String {
        guard let elevation = total_elevation_gain_ft else { return "Unknown" }
        return "\(Int(elevation)) ft"
    }
}
