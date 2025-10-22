//
//  SupabaseService.swift
//  RunnerInclineApp
//
//  Created by Dylan Dombrowski on 10/18/25.
//

import Foundation
import Supabase

final class SupabaseService {
    static let shared = SupabaseService()
    let client: SupabaseClient
    
    private init() {
        guard
            let info = Bundle.main.infoDictionary,
            let url = info["SUPABASE_URL"] as? String,
            let key = info["SUPABASE_ANON_KEY"] as? String
        else {
            fatalError("Missing Supabase configuration in Info.plist")
        }
        client = SupabaseClient(supabaseURL: URL(string: url)!, supabaseKey: key)
    }
    
    // MARK: - Storage Operations
    
    /// Upload GPX file to Supabase Storage
    func uploadGPXFile(data: Data, fileName: String) async throws -> String {
        let uploadResponse = try await client.storage
            .from("courses")
            .upload(fileName, data: data, options: .init(contentType: "application/gpx+xml"))
        
        return uploadResponse.path
    }
    
    /// Trigger Edge Function to process uploaded GPX
    func processGPXFile(filePath: String, courseId: UUID) async throws {
        struct ProcessGPXPayload: Codable {
            let gpx_path: String
            let course_id: String
        }
        
        let payload = ProcessGPXPayload(
            gpx_path: filePath,
            course_id: courseId.uuidString
        )
        
        try await client.functions
            .invoke("process-gpx", options: .init(body: payload))
    }
    
    // MARK: - Database Operations
    
    /// Create a new course entry (requires authentication)
    func createCourse(name: String, city: String?, distanceMiles: Double?, gpxUrl: String?) async throws -> Course {
        struct CourseInsert: Codable {
            let name: String
            let city: String?
            let distance_miles: Double?
            let gpx_url: String?
            let verified: Bool
            let created_by: UUID?
        }
        
        // Get current user
        let user = try await client.auth.user()
        
        let courseData = CourseInsert(
            name: name,
            city: city,
            distance_miles: distanceMiles,
            gpx_url: gpxUrl,
            verified: false,
            created_by: user.id
        )
        
        let response: Course = try await client
            .from("courses")
            .insert(courseData)
            .select()
            .single()
            .execute()
            .value
        
        return response
    }
}
