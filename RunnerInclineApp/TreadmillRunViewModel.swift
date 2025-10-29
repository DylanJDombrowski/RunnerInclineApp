//
//  TreadmillRunViewModel.swift
//  RunnerInclineApp
//
//  Created by AI Assistant on 10/28/25.
//

import Foundation
import Combine
import Supabase

@MainActor
final class TreadmillRunViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var currentDistance: Double = 0.0
    @Published var currentIncline: Double = 0.0
    @Published var currentPace: Double = 420 // seconds per mile (7:00/mi default)
    @Published var nextIncline: Double = 0.0
    @Published var nextPace: Double = 420
    @Published var distanceToNextChange: Double = 0.0
    
    @Published var isRunning = false
    @Published var isLoading = false
    @Published var segments: [Segment] = []
    @Published var paceSegments: [PaceSegment] = []
    
    // MARK: - Private Properties
    private let course: Course
    private var timer: Timer?
    private var startTime: Date?
    private let incrementPerSecond: Double = 0.1 / 10 // 1 mile per 10 seconds = 0.1 miles per second, divided by 10 for 0.1s intervals
    
    // MARK: - Computed Properties
    var currentPaceFormatted: String {
        let minutes = Int(currentPace) / 60
        let seconds = Int(currentPace) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var nextPaceFormatted: String {
        let minutes = Int(nextPace) / 60
        let seconds = Int(nextPace) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var currentInclineFormatted: String {
        return String(format: "%.1f%%", currentIncline)
    }
    
    var nextInclineFormatted: String {
        return String(format: "%.1f%%", nextIncline)
    }
    
    var distanceToNextChangeFormatted: String {
        return String(format: "%.2f mi", distanceToNextChange)
    }
    
    var currentDistanceFormatted: String {
        return String(format: "%.2f mi", currentDistance)
    }
    
    var totalDistance: Double {
        return course.distance_miles ?? 26.2
    }
    
    var progressPercentage: Double {
        return min(currentDistance / totalDistance, 1.0)
    }
    
    // MARK: - Initialization
    init(course: Course) {
        self.course = course
    }
    
    // MARK: - Data Loading
    func loadData() async {
        isLoading = true
        
        do {
            // Load segments
            let segmentsResponse: [Segment] = try await SupabaseService.shared.client
                .from("segments")
                .select()
                .eq("course_id", value: course.id)
                .order("segment_index", ascending: true)
                .execute()
                .value
            
            // Load pace segments
            let paceSegmentsResponse: [PaceSegment] = try await SupabaseService.shared.client
                .from("pace_segments")
                .select()
                .eq("course_id", value: course.id)
                .order("segment_index", ascending: true)
                .execute()
                .value
            
            self.segments = segmentsResponse
            self.paceSegments = paceSegmentsResponse
            
            // Initialize current values
            updateCurrentValues()
            
            print("✅ Loaded \(segments.count) segments and \(paceSegments.count) pace segments")
            
        } catch {
            print("❌ Error loading run data: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Run Control
    func startRun() {
        guard !segments.isEmpty else { return }
        
        isRunning = true
        startTime = Date()
        
        // Start timer - updates every 0.1 seconds for smooth animation
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            Task { @MainActor in
                self.updateRunProgress()
            }
        }
    }
    
    func pauseRun() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func resumeRun() {
        guard !segments.isEmpty else { return }
        isRunning = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            Task { @MainActor in
                self.updateRunProgress()
            }
        }
    }
    
    func endRun() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        
        // Reset to start
        currentDistance = 0.0
        updateCurrentValues()
    }
    
    // MARK: - Private Methods
    private func updateRunProgress() {
        // Increment distance (1 mile per 10 seconds)
        currentDistance += incrementPerSecond
        
        // Check if we've completed the course
        if currentDistance >= totalDistance {
            currentDistance = totalDistance
            endRun()
            return
        }
        
        updateCurrentValues()
    }
    
    private func updateCurrentValues() {
        // Find current segment based on distance
        let currentSegment = findSegmentForDistance(currentDistance)
        let nextSegment = findSegmentForDistance(currentDistance + 0.1)
        
        // Update incline values
        if let segment = currentSegment {
            currentIncline = segment.grade_percent ?? 0.0
        }
        
        if let segment = nextSegment {
            nextIncline = segment.grade_percent ?? 0.0
            distanceToNextChange = segment.distance_miles - currentDistance
        }
        
        // Update pace values
        let currentPaceSegment = findPaceSegmentForDistance(currentDistance)
        let nextPaceSegment = findPaceSegmentForDistance(currentDistance + 0.1)
        
        if let paceSegment = currentPaceSegment {
            currentPace = Double(paceSegment.recommended_pace_seconds_per_mile)
        }
        
        if let paceSegment = nextPaceSegment {
            nextPace = Double(paceSegment.recommended_pace_seconds_per_mile)
        }
        
        // If next values are the same as current, look further ahead
        if nextIncline == currentIncline || nextPace == currentPace {
            findNextChange()
        }
    }
    
    private func findSegmentForDistance(_ distance: Double) -> Segment? {
        return segments.last { $0.distance_miles <= distance }
    }
    
    private func findPaceSegmentForDistance(_ distance: Double) -> PaceSegment? {
        return paceSegments.last { $0.distance_miles <= distance }
    }
    
    private func findNextChange() {
        // Find the next segment where incline or pace actually changes
        for segment in segments.dropFirst() {
            if segment.distance_miles > currentDistance {
                let segmentIncline = segment.grade_percent ?? 0.0
                if segmentIncline != currentIncline {
                    nextIncline = segmentIncline
                    distanceToNextChange = segment.distance_miles - currentDistance
                    return
                }
            }
        }
        
        // If no incline change found, check for pace change
        for paceSegment in paceSegments.dropFirst() {
            if paceSegment.distance_miles > currentDistance {
                let segmentPace = Double(paceSegment.recommended_pace_seconds_per_mile)
                if segmentPace != currentPace {
                    nextPace = segmentPace
                    if distanceToNextChange == 0 {
                        distanceToNextChange = paceSegment.distance_miles - currentDistance
                    }
                    return
                }
            }
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}