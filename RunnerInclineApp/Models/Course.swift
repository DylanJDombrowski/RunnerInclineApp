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
}
