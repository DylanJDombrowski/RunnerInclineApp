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
        print("☁️ SupabaseService: Starting GPX upload...")
        print("📁 Filename: \(fileName)")
        print("💾 Data size: \(data.count) bytes")
        
        do {
            let uploadResponse = try await client.storage
                .from("courses")
                .upload(fileName, data: data, options: .init(contentType: "application/gpx+xml"))
            
            print("✅ SupabaseService: Upload successful")
            print("📍 File path: \(uploadResponse.path)")
            return uploadResponse.path
            
        } catch {
            print("❌ SupabaseService: Upload failed")
            print("❌ Error: \(error)")
            print("❌ Localized: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Trigger Edge Function to process uploaded GPX
    func processGPXFile(filePath: String, courseId: UUID) async throws {
        print("⚙️ SupabaseService: Starting Edge Function call...")
        print("🔗 GPX path: \(filePath)")
        print("🆔 Course ID: \(courseId)")
        
        struct ProcessGPXPayload: Codable {
            let gpx_path: String
            let course_id: String
        }
        
        let payload = ProcessGPXPayload(
            gpx_path: filePath,
            course_id: courseId.uuidString
        )
        
        print("📦 Payload: \(payload)")
        
        do {
            try await client.functions
                .invoke("process-gpx", options: .init(body: payload))
            
            print("✅ SupabaseService: Edge Function call successful")
            
        } catch {
            print("❌ SupabaseService: Edge Function call failed")
            print("❌ Error: \(error)")
            print("❌ Localized: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Database Operations
    
    /// Create a new course entry (requires authentication)
    func createCourse(name: String, city: String?, distanceMiles: Double?, gpxUrl: String?) async throws -> Course {
        print("📊 SupabaseService: Starting course creation...")
        print("📝 Name: \(name)")
        print("🏙️ City: \(city ?? "N/A")")
        print("📏 Distance: \(distanceMiles ?? 0.0) miles")
        
        struct CourseInsert: Codable {
            let name: String
            let city: String?
            let distance_miles: Double?
            let gpx_url: String?
            let verified: Bool
            let created_by: UUID?
        }
        
        do {
            // Get current user
            print("👤 Getting current user...")
            let user = try await client.auth.user()
            print("✅ User ID: \(user.id)")
            
            let courseData = CourseInsert(
                name: name,
                city: city,
                distance_miles: distanceMiles,
                gpx_url: gpxUrl,
                verified: false,
                created_by: user.id
            )
            
            print("📦 Course data: \(courseData)")
            print("💾 Inserting course into database and returning the actual ID...")
            
            // Insert and get the actual course back with the real database ID
            let response: Course = try await client
                .from("courses")
                .insert(courseData)
                .select()
                .single()
                .execute()
                .value
            
            print("✅ Course inserted with actual database ID: \(response.id)")
            print("✅ SupabaseService: Course creation complete")
            return response
            
        } catch {
            print("❌ SupabaseService: Course creation failed")
            print("❌ Error: \(error)")
            print("❌ Localized: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Fetch pace segments for a course
    func fetchPaceSegments(for courseId: UUID) async throws -> [PaceSegment] {
        print("📊 SupabaseService: Fetching pace segments for course \(courseId)")
        
        do {
            let response: [PaceSegment] = try await client
                .from("pace_segments")
                .select()
                .eq("course_id", value: courseId)
                .order("segment_index", ascending: true)
                .execute()
                .value
            
            print("✅ SupabaseService: Loaded \(response.count) pace segments")
            return response
            
        } catch {
            print("❌ SupabaseService: Failed to load pace segments")
            print("❌ Error: \(error)")
            throw error
        }
    }
    
    /// Fetch segments for a course
    func fetchSegments(for courseId: UUID) async throws -> [Segment] {
        print("📊 SupabaseService: Fetching segments for course \(courseId)")
        
        do {
            let response: [Segment] = try await client
                .from("segments")
                .select()
                .eq("course_id", value: courseId)
                .order("segment_index", ascending: true)
                .execute()
                .value
            
            print("✅ SupabaseService: Loaded \(response.count) segments")
            return response
            
        } catch {
            print("❌ SupabaseService: Failed to load segments")
            print("❌ Error: \(error)")
            throw error
        }
    }
}
