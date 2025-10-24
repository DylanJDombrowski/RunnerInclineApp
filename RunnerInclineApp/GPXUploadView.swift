//
//  GPXUploadView.swift
//  RunnerInclineApp
//
//  Created by Dylan Dombrowski on 10/20/25.
//

import SwiftUI
import UniformTypeIdentifiers
import Combine

struct GPXUploadView: View {
    @StateObject private var viewModel = GPXUploadViewModel()
    @StateObject private var authManager = AuthenticationManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var courseName = ""
    @State private var courseCity = ""
    @State private var distanceMiles = ""
    @State private var showingFilePicker = false
    @State private var showingAuthView = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Course Information") {
                    TextField("Marathon Name", text: $courseName)
                    TextField("City (Optional)", text: $courseCity)
                    TextField("Distance (Miles)", text: $distanceMiles)
                        .keyboardType(.decimalPad)
                }
                
                Section("GPX File") {
                    if let fileName = viewModel.selectedFileName {
                        HStack {
                            Image(systemName: "doc.badge.gearshape")
                                .foregroundColor(.green)
                            Text(fileName)
                            Spacer()
                        }
                    } else {
                        Button("Select GPX File") {
                            showingFilePicker = true
                        }
                        
                        // Development helper
                        Button("Use Test GPX") {
                            viewModel.createTestGPX()
                        }
                        .foregroundColor(.orange)
                    }
                }
                
                if viewModel.isUploading {
                    Section {
                        HStack {
                            ProgressView()
                            Text("Processing GPX...")
                        }
                    }
                }
                
                if !viewModel.statusMessage.isEmpty {
                    Section {
                        Text(viewModel.statusMessage)
                            .foregroundColor(viewModel.hasError ? .red : .green)
                    }
                }
            }
            .navigationTitle("Upload Course")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Upload") {
                        if authManager.isAuthenticated {
                            Task {
                                await viewModel.uploadGPXFile(
                                    name: courseName,
                                    city: courseCity.isEmpty ? nil : courseCity,
                                    distanceMiles: Double(distanceMiles)
                                )
                            }
                        } else {
                            showingAuthView = true
                        }
                    }
                    .disabled(courseName.isEmpty || viewModel.selectedFileData == nil || viewModel.isUploading)
                }
            }
        }
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.xml, .plainText, .data, .item],
            allowsMultipleSelection: false
        ) { result in
            viewModel.handleFileSelection(result)
        }
        .onChange(of: viewModel.uploadCompleted) { _, completed in
            if completed {
                dismiss()
            }
        }
        .onAppear {
            Task {
                await authManager.checkCurrentUser()
            }
        }
        .sheet(isPresented: $showingAuthView) {
            AuthenticationView()
                .environmentObject(authManager)
        }
        .onChange(of: authManager.isAuthenticated) { _, isAuthenticated in
            if isAuthenticated && showingAuthView {
                showingAuthView = false
                // Automatically trigger upload after successful authentication
                Task {
                    await viewModel.uploadGPXFile(
                        name: courseName,
                        city: courseCity.isEmpty ? nil : courseCity,
                        distanceMiles: Double(distanceMiles)
                    )
                }
            }
        }
    }
}

@MainActor
final class GPXUploadViewModel: ObservableObject {
    @Published var selectedFileName: String?
    @Published var selectedFileData: Data?
    @Published var isUploading = false
    @Published var statusMessage = ""
    @Published var hasError = false
    @Published var uploadCompleted = false
    
    func handleFileSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            do {
                let data = try Data(contentsOf: url)
                selectedFileData = data
                selectedFileName = url.lastPathComponent
                statusMessage = ""
                hasError = false
            } catch {
                statusMessage = "Failed to read file: \(error.localizedDescription)"
                hasError = true
            }
            
        case .failure(let error):
            statusMessage = "File selection failed: \(error.localizedDescription)"
            hasError = true
        }
    }
    
    func createTestGPX() {
        // Create a simple test GPX with elevation data (simulating part of Boston Marathon)
        let testGPXContent = """
        <?xml version="1.0" encoding="UTF-8"?>
        <gpx version="1.1" creator="RunnerInclineApp">
          <trk>
            <name>Test Marathon Course</name>
            <trkseg>
              <trkpt lat="42.3581" lon="-71.0636">
                <ele>10</ele>
              </trkpt>
              <trkpt lat="42.3590" lon="-71.0640">
                <ele>15</ele>
              </trkpt>
              <trkpt lat="42.3600" lon="-71.0650">
                <ele>25</ele>
              </trkpt>
              <trkpt lat="42.3610" lon="-71.0660">
                <ele>35</ele>
              </trkpt>
              <trkpt lat="42.3620" lon="-71.0670">
                <ele>50</ele>
              </trkpt>
              <trkpt lat="42.3630" lon="-71.0680">
                <ele>65</ele>
              </trkpt>
              <trkpt lat="42.3640" lon="-71.0690">
                <ele>80</ele>
              </trkpt>
              <trkpt lat="42.3650" lon="-71.0700">
                <ele>95</ele>
              </trkpt>
              <trkpt lat="42.3660" lon="-71.0710">
                <ele>110</ele>
              </trkpt>
              <trkpt lat="42.3670" lon="-71.0720">
                <ele>125</ele>
              </trkpt>
              <trkpt lat="42.3680" lon="-71.0730">
                <ele>140</ele>
              </trkpt>
              <trkpt lat="42.3690" lon="-71.0740">
                <ele>130</ele>
              </trkpt>
              <trkpt lat="42.3700" lon="-71.0750">
                <ele>115</ele>
              </trkpt>
              <trkpt lat="42.3710" lon="-71.0760">
                <ele>100</ele>
              </trkpt>
              <trkpt lat="42.3720" lon="-71.0770">
                <ele>85</ele>
              </trkpt>
            </trkseg>
          </trk>
        </gpx>
        """
        
        if let data = testGPXContent.data(using: .utf8) {
            selectedFileData = data
            selectedFileName = "test_marathon.gpx"
            statusMessage = "Test GPX file created"
            hasError = false
        }
    }
    
    func uploadGPXFile(name: String, city: String?, distanceMiles: Double?) async {
        guard let fileData = selectedFileData,
              let fileName = selectedFileName else { 
            print("❌ Upload failed: No file selected")
            statusMessage = "No file selected"
            hasError = true
            return 
        }
        
        isUploading = true
        statusMessage = "Creating course..."
        hasError = false
        print("🚀 Starting upload process...")
        print("📝 Course name: \(name)")
        print("🏙️ City: \(city ?? "N/A")")
        print("📏 Distance: \(distanceMiles ?? 0.0) miles")
        
        do {
            // Step 1: Create course entry in database
            print("📊 Step 1: Creating course in database...")
            let course = try await SupabaseService.shared.createCourse(
                name: name,
                city: city,
                distanceMiles: distanceMiles,
                gpxUrl: nil  // Will be updated after upload
            )
            print("✅ Step 1 Complete: Course created with ID: \(course.id)")
            
            statusMessage = "Uploading GPX file..."
            
            // Step 2: Upload GPX file to storage
            print("☁️ Step 2: Uploading GPX file to storage...")
            let uniqueFileName = "\(course.id.uuidString)_\(fileName)"
            print("📁 Unique filename: \(uniqueFileName)")
            print("💾 File size: \(fileData.count) bytes")
            
            let filePath = try await SupabaseService.shared.uploadGPXFile(
                data: fileData,
                fileName: uniqueFileName
            )
            print("✅ Step 2 Complete: File uploaded to path: \(filePath)")
            
            statusMessage = "Processing elevation data..."
            
            // Step 3: Trigger Edge Function to process GPX
            print("⚙️ Step 3: Triggering Edge Function...")
            print("🔗 GPX path: \(filePath)")
            print("🆔 Course ID: \(course.id)")
            
            try await SupabaseService.shared.processGPXFile(
                filePath: filePath,
                courseId: course.id
            )
            print("✅ Step 3 Complete: Edge Function triggered successfully")
            
            statusMessage = "Course uploaded successfully!"
            uploadCompleted = true
            print("🎉 Upload process completed successfully!")
            
        } catch {
            print("❌ Upload failed at some step:")
            print("❌ Error: \(error)")
            print("❌ Localized: \(error.localizedDescription)")
            
            // More detailed error information
            if let supabaseError = error as? (any Error) {
                print("❌ Error type: \(type(of: supabaseError))")
                print("❌ Full error: \(String(describing: supabaseError))")
            }
            
            statusMessage = "Upload failed: \(error.localizedDescription)"
            hasError = true
        }
        
        isUploading = false
    }
}

#Preview {
    GPXUploadView()
}