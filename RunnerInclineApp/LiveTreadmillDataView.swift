//
//  LiveTreadmillDataView.swift
//  RunnerInclineApp
//
//  Created by AI Assistant on 10/28/25.
//

import SwiftUI

struct LiveTreadmillDataView: View {
    @ObservedObject var viewModel: TreadmillRunViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // UP NEXT Section
            VStack(alignment: .leading, spacing: 8) {
                Text("UP NEXT")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(Color("LightText"))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Incline to \(viewModel.nextInclineFormatted)")
                        .font(.body)
                        .foregroundColor(Color("LightText"))
                    
                    Text("Pace to \(viewModel.nextPaceFormatted) /mi")
                        .font(.body)
                        .foregroundColor(Color("LightText"))
                    
                    Text("in \(viewModel.distanceToNextChangeFormatted)")
                        .font(.caption)
                        .foregroundColor(Color("MutedText"))
                }
            }
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            // CURRENT Section
            VStack(alignment: .leading, spacing: 16) {
                Text("CURRENT")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(Color("LightText"))
                
                HStack(spacing: 32) {
                    // Current Incline
                    VStack(alignment: .leading, spacing: 4) {
                        Text("INCLINE")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(Color("MutedText"))
                        
                        Text(viewModel.currentInclineFormatted)
                            .font(.system(.title, design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundColor(Color("ActionGreen"))
                            .contentTransition(.numericText())
                            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.currentIncline)
                    }
                    
                    // Current Pace
                    VStack(alignment: .leading, spacing: 4) {
                        Text("PACE")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(Color("MutedText"))
                        
                        Text("\(viewModel.currentPaceFormatted) /mi")
                            .font(.system(.title, design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundColor(Color("ActionGreen"))
                            .contentTransition(.numericText())
                            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.currentPace)
                    }
                }
            }
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            // Progress Info
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("DISTANCE")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(Color("MutedText"))
                    
                    Text(viewModel.currentDistanceFormatted)
                        .font(.system(.headline, design: .monospaced))
                        .fontWeight(.semibold)
                        .foregroundColor(Color("LightText"))
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.currentDistance)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("PROGRESS")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(Color("MutedText"))
                    
                    Text("\(Int(viewModel.progressPercentage * 100))%")
                        .font(.system(.headline, design: .monospaced))
                        .fontWeight(.semibold)
                        .foregroundColor(Color("LightText"))
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.progressPercentage)
                }
            }
        }
        .padding(24)
        .background {
            // Glassmorphism Background
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
}

#Preview {
    // Create a sample course for preview
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
    
    return ZStack {
        Color("OffBlack")
            .ignoresSafeArea()
        
        LiveTreadmillDataView(viewModel: viewModel)
            .padding()
    }
    .preferredColorScheme(.dark)
}