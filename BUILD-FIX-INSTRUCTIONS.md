// Quick Fix: Delete the Course.swift and Segment.swift files I created
// Your existing project already has these models defined somewhere
// 
// To fix the build errors:
// 1. In Xcode Project Navigator, search for "Course.swift" 
// 2. Delete any duplicate Course.swift files (keep only one)
// 3. Search for "Segment.swift"
// 4. Delete any duplicate Segment.swift files (keep only one) 
// 5. Clean Build Folder (Product → Clean Build Folder)
// 6. Build again
//
// The TreadmillRunViewModel and other new files should work with your existing models
// as long as they have the expected properties:
//
// Course needs: id, name, city, distance_miles, total_elevation_gain_ft, verified, created_by, created_at, updated_at
// Segment needs: id, course_id, segment_index, distance_miles, elevation_ft, grade_percent, created_at, updated_at
//
// If your existing models are missing any properties, let me know and I'll help add them.