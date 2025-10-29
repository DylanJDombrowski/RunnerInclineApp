//
//  LiveElevationChartView.swift
//  RunnerInclineApp
//
//  Created by AI Assistant on 10/28/25.
//

import SwiftUI
import Charts

struct LiveElevationChartView: View {
    @ObservedObject var viewModel: TreadmillRunViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("ELEVATION PROFILE")
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(Color("LightText"))
            
            Chart {
                // Base elevation area
                ForEach(viewModel.segments) { segment in
                    AreaMark(
                        x: .value("Distance", segment.distance_miles),
                        y: .value("Elevation", segment.elevation_ft)
                    )
                    .foregroundStyle(elevationGradient)
                }
                
                // Elevation line
                ForEach(viewModel.segments) { segment in
                    LineMark(
                        x: .value("Distance", segment.distance_miles),
                        y: .value("Elevation", segment.elevation_ft)
                    )
                    .foregroundStyle(Color("ActionGreen"))
                }
                
                // Live progress indicators
                if viewModel.currentDistance > 0 {
                    RuleMark(x: .value("Current", viewModel.currentDistance))
                        .foregroundStyle(Color("LightText").opacity(0.8))
                    
                    if let currentSegment = viewModel.segments.last(where: { $0.distance_miles <= viewModel.currentDistance }) {
                        PointMark(
                            x: .value("Current", viewModel.currentDistance),
                            y: .value("Elevation", currentSegment.elevation_ft)
                        )
                        .foregroundStyle(Color("LightText"))
                        .symbolSize(64)
                    }
                }
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(Color.white.opacity(0.2))
                    AxisTick(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(Color.white.opacity(0.2))
                    AxisValueLabel {
                        if let distance = value.as(Double.self) {
                            Text("\(Int(distance))")
                                .font(.caption2)
                                .foregroundColor(Color("MutedText"))
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(Color.white.opacity(0.2))
                    AxisTick(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(Color.white.opacity(0.2))
                    AxisValueLabel {
                        if let elevation = value.as(Double.self) {
                            Text("\(Int(elevation))")
                                .font(.caption2)
                                .foregroundColor(Color("MutedText"))
                        }
                    }
                }
            }
            .chartXAxisLabel {
                Text("Distance (miles)")
                    .font(.caption)
                    .foregroundColor(Color("MutedText"))
            }
            .chartYAxisLabel {
                Text("Elevation (ft)")
                    .font(.caption)
                    .foregroundColor(Color("MutedText"))
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.currentDistance)
        }
        .padding(24)
        .background {
            ZStack {
                Color("DarkGray")
                Color.clear
                    .background(.ultraThinMaterial)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            }
        }
    }
    
    // Gradient for elevation area
    private var elevationGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color("ActionGreen").opacity(0.4),
                Color("ActionGreen").opacity(0.0)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

#Preview {
    let sampleCourse = Course(
        id: UUID(),
        name: "Boston Marathon",
        city: "Boston, MA",
        distance_miles: 26.2,
        total_elevation_gain_ft: 500,
        gpx_url: nil,
        verified: true,
        created_by: nil,
        created_at: Date(),
        updated_at: Date()
    )
    
    let viewModel = TreadmillRunViewModel(course: sampleCourse)
    
    let sampleSegments = [
        Segment(id: UUID(), course_id: sampleCourse.id, segment_index: 0, distance_miles: 0.0, elevation_ft: 100, grade_percent: 0.0, created_at: Date(), updated_at: Date()),
        Segment(id: UUID(), course_id: sampleCourse.id, segment_index: 1, distance_miles: 5.0, elevation_ft: 200, grade_percent: 2.0, created_at: Date(), updated_at: Date())
    ]
    
    ZStack {
        Color("OffBlack")
            .ignoresSafeArea()
        
        VStack {
            LiveElevationChartView(viewModel: viewModel)
                .onAppear {
                    viewModel.segments = sampleSegments
                    viewModel.currentDistance = 2.5
                }
        }
        .padding()
    }
    .preferredColorScheme(.dark)
}