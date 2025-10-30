// Test your Segment model structure
// Add this temporarily to see what fields your Segment expects

import Foundation

// This will show us what your current Segment model looks like
extension Segment {
    static func debugSchema() {
        print("🔍 DEBUG: Segment model expects these fields:")
        let mirror = Mirror(reflecting: Segment.self)
        for child in mirror.children {
            if let label = child.label {
                print("   - \(label): \(type(of: child.value))")
            }
        }
    }
}

// Test JSON decoding with your database data
extension SegmentViewModel {
    func testSegmentDecoding() {
        let sampleJSON = """
        {
            "id": "6f03a4f8-24ff-448a-bd2a-84ef14b29825",
            "course_id": "48fde145-7045-43c6-bfb9-eaa86beaa0e1", 
            "segment_index": 0,
            "distance_miles": 0,
            "elevation_ft": 100,
            "grade_percent": 0,
            "created_at": "2025-10-30T03:29:42.374639+00:00",
            "updated_at": null
        }
        """
        
        print("🔍 DEBUG: Testing manual segment decoding...")
        
        if let data = sampleJSON.data(using: .utf8) {
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let segment = try decoder.decode(Segment.self, from: data)
                print("✅ DEBUG: Manual decode successful: \(segment)")
            } catch {
                print("❌ DEBUG: Manual decode failed: \(error)")
            }
        }
    }
}