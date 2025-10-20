//
//  GPXUploadView.swift
//  RunnerInclineApp
//
//  Created by Dylan Dombrowski on 10/20/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct GPXUploadView: View {
    @StateObject private var viewModel = GPXUploadViewModel()
    @Environment(\.dismiss) private var dismiss
    
    @State private var courseName = ""
    @State private var courseCity = ""
    @State private var distanceMiles = ""
    @State private var showingFilePicker = false
    
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
                        Task {
                            await viewModel.uploadGPXFile(
                                name: courseName,
                                city: courseCity.isEmpty ? nil : courseCity,
                                distanceMiles: Double(distanceMiles)
                            )
                        }
                    }
                    .disabled(courseName.isEmpty || viewModel.selectedFileData == nil || viewModel.isUploading)
                }
            }
        }
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [UTType.xml, UTType.data],
            allowsMultipleSelection: false
        ) { result in
            viewModel.handleFileSelection(result)
        }
        .onChange(of: viewModel.uploadCompleted) { completed in
            if completed {
                dismiss()
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
    
    func uploadGPXFile(name: String, city: String?, distanceMiles: Double?) async {
        guard let fileData = selectedFileData,
              let fileName = selectedFileName else { return }
        
        isUploading = true
        statusMessage = "Creating course..."
        hasError = false
        
        do {
            // 1. Create course entry in database
            let course = try await SupabaseService.shared.createCourse(
                name: name,
                city: city,
                distanceMiles: distanceMiles,
                gpxUrl: nil  // Will be updated after upload
            )
            
            statusMessage = "Uploading GPX file..."
            
            // 2. Upload GPX file to storage
            let uniqueFileName = "\(course.id.uuidString)_\(fileName)"
            let filePath = try await SupabaseService.shared.uploadGPXFile(
                data: fileData,
                fileName: uniqueFileName
            )
            
            statusMessage = "Processing elevation data..."
            
            // 3. Trigger Edge Function to process GPX
            try await SupabaseService.shared.processGPXFile(
                filePath: filePath,
                courseId: course.id
            )
            
            statusMessage = "Course uploaded successfully!"
            uploadCompleted = true
            
        } catch {
            statusMessage = "Upload failed: \(error.localizedDescription)"
            hasError = true
        }
        
        isUploading = false
    }
}

#Preview {
    GPXUploadView()
}