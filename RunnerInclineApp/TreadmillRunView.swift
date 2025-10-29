//
//  TreadmillRunView.swift
//  RunnerInclineApp
//
//  Created by AI Assistant on 10/28/25.
//

import SwiftUI

struct TreadmillRunView: View {
    let course: Course
    @StateObject private var viewModel: TreadmillRunViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isMinimized = false
    
    init(course: Course) {
        self.course = course
        self._viewModel = StateObject(wrappedValue: TreadmillRunViewModel(course: course))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color("OffBlack")
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    loadingView
                } else if !isMinimized {
                    fullScreenContent
                        .transition(.opacity.combined(with: .scale))
                } else {
                    minimizedView
                        .transition(.opacity.combined(with: .scale))
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.loadData()
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isMinimized)
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 24) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(Color("ActionGreen"))
            
            Text("Loading run data...")
                .font(.headline)
                .foregroundColor(Color("LightText"))
                
            Text(course.name)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Color("ActionGreen"))
        }
    }
    
    // MARK: - Full Screen Content
    private var fullScreenContent: some View {
        VStack(spacing: 32) {
            // Header
            headerView
            
            ScrollView {
                VStack(spacing: 32) {
                    // Live Treadmill Data
                    LiveTreadmillDataView(viewModel: viewModel)
                    
                    // Elevation Chart
                    LiveElevationChartView(viewModel: viewModel)
                    
                    Spacer(minLength: 100) // Space for controls
                }
                .padding(.horizontal, 24)
            }
            
            Spacer()
            
            // Control Buttons
            controlButtons
        }
    }
    
    // MARK: - Minimized View
    private var minimizedView: some View {
        VStack {
            // Minimized header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(course.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("LightText"))
                        .lineLimit(1)
                    
                    HStack(spacing: 16) {
                        Text(viewModel.currentDistanceFormatted)
                            .font(.system(.subheadline, design: .monospaced))
                            .foregroundColor(Color("ActionGreen"))
                            .contentTransition(.numericText())
                        
                        Text("•")
                            .foregroundColor(Color("MutedText"))
                        
                        Text(viewModel.currentInclineFormatted)
                            .font(.system(.subheadline, design: .monospaced))
                            .foregroundColor(Color("ActionGreen"))
                            .contentTransition(.numericText())
                        
                        Text("•")
                            .foregroundColor(Color("MutedText"))
                        
                        Text(viewModel.currentPaceFormatted)
                            .font(.system(.subheadline, design: .monospaced))
                            .foregroundColor(Color("ActionGreen"))
                            .contentTransition(.numericText())
                    }
                }
                
                Spacer()
                
                // Quick controls
                HStack(spacing: 16) {
                    Button {
                        if viewModel.isRunning {
                            viewModel.pauseRun()
                        } else {
                            if viewModel.currentDistance == 0 {
                                viewModel.startRun()
                            } else {
                                viewModel.resumeRun()
                            }
                        }
                    } label: {
                        Image(systemName: viewModel.isRunning ? "pause.fill" : "play.fill")
                            .font(.title2)
                            .foregroundColor(Color("ActionGreen"))
                    }
                    
                    Button {
                        withAnimation {
                            isMinimized = false
                        }
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundColor(Color("LightText"))
                    }
                }
            }
            .padding(20)
            .background {
                ZStack {
                    Color("DarkGray")
                    Color.clear.background(.ultraThinMaterial)
                }
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 60) // Account for status bar
            
            Spacer()
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 16) {
            // Top controls
            HStack {
                Button("End Run") {
                    viewModel.endRun()
                    dismiss()
                }
                .font(.headline)
                .foregroundColor(Color("LightText"))
                
                Spacer()
                
                Button {
                    withAnimation {
                        isMinimized = true
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundColor(Color("LightText"))
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            
            // Course title
            VStack(spacing: 4) {
                Text(course.name)
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("LightText"))
                    .multilineTextAlignment(.center)
                
                if let city = course.city {
                    Text(city)
                        .font(.subheadline)
                        .foregroundColor(Color("MutedText"))
                }
            }
        }
    }
    
    // MARK: - Control Buttons
    private var controlButtons: some View {
        HStack(spacing: 24) {
            if !viewModel.isRunning && viewModel.currentDistance > 0 {
                // Resume button
                Button {
                    viewModel.resumeRun()
                } label: {
                    Label("Resume", systemImage: "play.fill")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color("ActionGreen"))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(PrimaryButtonStyle())
                
                // End button
                Button {
                    viewModel.endRun()
                    dismiss()
                } label: {
                    Label("End", systemImage: "stop.fill")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("LightText"))
                        .frame(width: 100)
                        .frame(height: 56)
                        .background {
                            ZStack {
                                Color("DarkGray")
                                Color.clear.background(.ultraThinMaterial)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay {
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            }
                        }
                }
                .buttonStyle(SecondaryButtonStyle())
            } else if viewModel.isRunning {
                // Pause button
                Button {
                    viewModel.pauseRun()
                } label: {
                    Label("Pause", systemImage: "pause.fill")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color("ActionGreen"))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(PrimaryButtonStyle())
            } else {
                // Start button
                Button {
                    viewModel.startRun()
                } label: {
                    Label("Start Run", systemImage: "play.fill")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color("ActionGreen"))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(viewModel.segments.isEmpty)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
    }
}

// MARK: - Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.8), value: configuration.isPressed)
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
    
    return TreadmillRunView(course: sampleCourse)
        .preferredColorScheme(.dark)
}