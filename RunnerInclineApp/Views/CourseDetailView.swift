//
//  CourseDetailView.swift
//  RunnerInclineApp
//
//  Created by Dylan Dombrowski on 10/19/25.
//

import SwiftUI
import Charts  // Apple’s Charts framework (built in since iOS 16)

struct CourseDetailView: View {
    let course: Course
    @StateObject private var vm = SegmentViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Course header
                VStack(alignment: .leading, spacing: 8) {
                    Text(course.name)
                        .font(.largeTitle.bold())
                    
                    HStack {
                        if let city = course.city {
                            Text(city).foregroundColor(.secondary)
                        }
                        Spacer()
                        if course.verified {
                            Label("Verified", systemImage: "checkmark.shield")
                                .foregroundColor(.green)
                                .font(.caption.weight(.medium))
                        }
                    }
                    
                    // Course stats
                    HStack(spacing: 20) {
                        if let distance = course.distance_miles {
                            VStack(alignment: .leading) {
                                Text("Distance")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(distance, specifier: "%.1f") mi")
                                    .font(.headline)
                            }
                        }
                        
                        if let elevation = course.total_elevation_gain_ft {
                            VStack(alignment: .leading) {
                                Text("Elevation Gain")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(Int(elevation)) ft")
                                    .font(.headline)
                            }
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Segments")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(vm.segments.count)")
                                .font(.headline)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                Divider()
                
                if vm.isLoading {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Loading incline data…")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                } else if vm.segments.isEmpty {
                    ContentUnavailableView(
                        "No Incline Data",
                        systemImage: "chart.line.uptrend.xyaxis",
                        description: Text("This course doesn't have elevation segments yet.")
                    )
                    .frame(height: 200)
                } else {
                    // Elevation Chart
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Elevation Profile")
                            .font(.headline)
                        
                        Chart(vm.segments) { segment in
                            LineMark(
                                x: .value("Mile", segment.mile_start),
                                y: .value("Incline %", segment.incline_percent)
                            )
                            .foregroundStyle(.blue)
                        }
                        .frame(height: 200)
                        .chartYAxis {
                            AxisMarks(position: .leading) { value in
                                AxisGridLine()
                                AxisTick()
                                AxisValueLabel {
                                    Text("\(value.as(Double.self) ?? 0, specifier: "%.0f")%")
                                        .font(.caption2)
                                }
                            }
                        }
                        .chartXAxis {
                            AxisMarks { value in
                                AxisGridLine()
                                AxisTick()
                                AxisValueLabel {
                                    Text("Mile \(Int(value.as(Double.self) ?? 0))")
                                        .font(.caption2)
                                }
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Segment Details
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Incline Breakdown")
                            .font(.headline)
                        
                        LazyVStack(spacing: 8) {
                            ForEach(vm.segments.prefix(15)) { segment in
                                HStack {
                                    Text("Mile \(segment.mile_start, specifier: "%.1f")–\(segment.mile_end, specifier: "%.1f")")
                                        .font(.subheadline)
                                    Spacer()
                                    HStack(spacing: 4) {
                                        Text("\(segment.incline_percent, specifier: "%.1f")%")
                                            .font(.subheadline.weight(.medium))
                                            .foregroundColor(inclineColor(segment.incline_percent))
                                        
                                        Image(systemName: inclineIcon(segment.incline_percent))
                                            .font(.caption)
                                            .foregroundColor(inclineColor(segment.incline_percent))
                                    }
                                }
                                .padding(.vertical, 2)
                            }
                            
                            if vm.segments.count > 15 {
                                Text("... and \(vm.segments.count - 15) more segments")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(course.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Refresh", systemImage: "arrow.clockwise") {
                    vm.refreshSegments(for: course.id)
                }
                .disabled(vm.isLoading)
            }
        }
        .onAppear {
            vm.fetchSegments(for: course.id)
        }
    }
    
    private func inclineColor(_ incline: Double) -> Color {
        switch incline {
        case ..<(-2): return .blue      // Steep downhill
        case -2..<0: return .cyan       // Gentle downhill
        case 0: return .gray            // Flat
        case 0..<3: return .green       // Easy uphill
        case 3..<6: return .orange      // Moderate uphill
        default: return .red            // Steep uphill
        }
    }
    
    private func inclineIcon(_ incline: Double) -> String {
        switch incline {
        case ..<(-1): return "arrow.down.right"
        case -1..<1: return "arrow.right"
        default: return "arrow.up.right"
        }
    }
}
