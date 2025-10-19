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
                Text(course.name)
                    .font(.largeTitle.bold())
                if let city = course.city {
                    Text(city).foregroundColor(.secondary)
                }
                
                if vm.segments.isEmpty {
                    ProgressView("Loading incline data…")
                        .frame(maxWidth: .infinity)
                } else {
                    // Elevation Chart
                    Chart(vm.segments) { seg in
                        LineMark(
                            x: .value("Mile", seg.mile_start),
                            y: .value("Incline %", seg.incline_percent)
                        )
                    }
                    .frame(height: 200)
                    .padding(.vertical)
                    
                    // Segment summary list
                    ForEach(vm.segments.prefix(10)) { seg in
                        HStack {
                            Text("Miles \(String(format: "%.1f", seg.mile_start))–\(String(format: "%.1f", seg.mile_end))")
                            Spacer()
                            Text("\(seg.incline_percent, specifier: "%.1f")%")
                                .foregroundColor(seg.incline_percent > 0 ? .green : .red)
                        }
                        Divider()
                    }
                }
            }
            .padding()
        }
        .navigationTitle(course.name)
        .onAppear {
            vm.fetchSegments(for: course.id)
        }
    }
}
