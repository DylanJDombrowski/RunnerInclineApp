# 🔧 Implementation: Real GPX File Upload
## Sprint 3 - Week 1 Focus

---

## 🎯 **GOAL: Remove Test GPX, Add Real File Support**

Replace the hardcoded "Use Test GPX" button with real .gpx file selection and upload capabilities.

---

## 📋 **STEP-BY-STEP IMPLEMENTATION**

### **Step 1: Update GPXUploadView File Selection**

#### **Current Code** (GPXUploadView.swift)
```swift
// Development helper - REMOVE THIS
Button("Use Test GPX") {
    viewModel.createTestGPX()
}
.foregroundColor(.orange)
```

#### **New Code** (Enhanced .fileImporter)
```swift
// Replace the "Use Test GPX" section with:
VStack(alignment: .leading, spacing: 8) {
    Button("Select GPX File") {
        showingFilePicker = true
    }
    .buttonStyle(.bordered)
    
    Text("Supported: .gpx files up to 50MB")
        .font(.caption)
        .foregroundColor(.secondary)
}
```

#### **Update .fileImporter**
```swift
.fileImporter(
    isPresented: $showingFilePicker,
    allowedContentTypes: [.init(filenameExtension: "gpx")!], // GPX only
    allowsMultipleSelection: false
) { result in
    viewModel.handleRealGPXFile(result)
}
```

### **Step 2: Enhance GPXUploadViewModel**

#### **Add Real File Handling**
```swift
// Replace createTestGPX() with:
func handleRealGPXFile(_ result: Result<[URL], Error>) {
    switch result {
    case .success(let urls):
        guard let url = urls.first else { return }
        
        do {
            // Security check - ensure we can access the file
            guard url.startAccessingSecurityScopedResource() else {
                statusMessage = "Cannot access selected file"
                hasError = true
                return
            }
            defer { url.stopAccessingSecurityScopedResource() }
            
            // Read file data
            let data = try Data(contentsOf: url)
            
            // Validate file size (max 50MB)
            guard data.count < 50 * 1024 * 1024 else {
                statusMessage = "File too large (max 50MB)"
                hasError = true
                return
            }
            
            // Validate GPX content
            guard let gpxString = String(data: data, encoding: .utf8),
                  gpxString.contains("<gpx") else {
                statusMessage = "Invalid GPX file format"
                hasError = true
                return
            }
            
            // Success - store the data
            selectedFileData = data
            selectedFileName = url.lastPathComponent
            statusMessage = "GPX file loaded successfully (\(formatFileSize(data.count)))"
            hasError = false
            
            // Auto-extract metadata if possible
            extractGPXMetadata(from: gpxString)
            
        } catch {
            statusMessage = "Failed to read file: \(error.localizedDescription)"
            hasError = true
        }
        
    case .failure(let error):
        statusMessage = "File selection failed: \(error.localizedDescription)"
        hasError = true
    }
}

// Add helper functions
private func formatFileSize(_ bytes: Int) -> String {
    let formatter = ByteCountFormatter()
    formatter.allowedUnits = [.useKB, .useMB]
    formatter.countStyle = .file
    return formatter.string(fromByteCount: Int64(bytes))
}

private func extractGPXMetadata(from gpxString: String) {
    // Try to extract basic metadata
    // This is optional but nice UX
    
    // Extract track name
    if let nameRange = gpxString.range(of: "<name>(.*?)</name>", options: .regularExpression) {
        let name = String(gpxString[nameRange])
            .replacingOccurrences(of: "<name>", with: "")
            .replacingOccurrences(of: "</name>", with: "")
        // Could auto-populate course name field
    }
    
    // Extract track points count for validation
    let trkptCount = gpxString.components(separatedBy: "<trkpt").count - 1
    if trkptCount > 0 {
        statusMessage += " • \(trkptCount) track points"
    }
}
```

### **Step 3: Remove Test GPX Function**

#### **Delete from GPXUploadViewModel**
```swift
// DELETE THIS ENTIRE FUNCTION
func createTestGPX() {
    // ... all the hardcoded test data
}
```

### **Step 4: Add File Preview (Optional Enhancement)**

#### **Add to GPXUploadView**
```swift
// In the "GPX File" section, after file selection:
if let fileName = viewModel.selectedFileName,
   let fileSize = viewModel.selectedFileSize {
    
    VStack(alignment: .leading, spacing: 4) {
        HStack {
            Image(systemName: "doc.badge.gearshape")
                .foregroundColor(.green)
            VStack(alignment: .leading) {
                Text(fileName)
                    .font(.subheadline)
                Text(fileSize)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            
            Button("Change") {
                viewModel.clearSelectedFile()
                showingFilePicker = true
            }
            .font(.caption)
        }
        
        if let metadata = viewModel.gpxMetadata {
            Text("📊 \(metadata)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    .padding()
    .background(Color.green.opacity(0.1))
    .cornerRadius(8)
}
```

---

## 🧪 **TESTING PLAN**

### **Test 1: File Selection**
- [ ] Tap "Select GPX File" → File picker opens
- [ ] Select a .gpx file → Shows file name and size
- [ ] Try selecting non-.gpx file → Should be filtered out

### **Test 2: File Validation** 
- [ ] Select very large file (>50MB) → Error message
- [ ] Select empty file → Error message  
- [ ] Select non-GPX file renamed to .gpx → Error message
- [ ] Select valid GPX → Success message with metadata

### **Test 3: Upload Process**
- [ ] Select Boston Marathon GPX file
- [ ] Fill in course details
- [ ] Tap "Upload" → Should complete successfully
- [ ] Check course detail → Should show realistic elevation profile

### **Test 4: Edge Cases**
- [ ] Cancel file picker → No crash
- [ ] Select file, then select different file → Replaces correctly
- [ ] Upload without selecting file → Proper error handling

---

## 📊 **SUCCESS CRITERIA**

After implementing these changes:

✅ **No more test data** - "Use Test GPX" button completely removed  
✅ **Real file support** - Can select and upload actual .gpx files  
✅ **File validation** - Proper error handling for invalid files  
✅ **User feedback** - Clear messages about file status and metadata  
✅ **Boston Marathon upload** - Can upload and view a real marathon course  

---

## 🚀 **NEXT PHASE**

Once real file upload works:

1. **Get 5+ Major Marathon GPX Files** - Boston, NYC, London, Chicago, Berlin
2. **Add Course Auto-Detection** - Parse course name, distance, location from GPX
3. **Bulk Upload Tool** - Admin interface for seeding popular courses  
4. **Course Search** - Find courses by name, location, distance
5. **Difficulty Rating** - Calculate hill difficulty score

---

## 💡 **PRO TIPS**

### **Finding Good GPX Files**
- **Strava**: Search "Boston Marathon 2024" → Find actual race finisher routes
- **Garmin Connect**: Search courses → Download shared marathon routes
- **Race Websites**: Some races provide official GPX downloads
- **Running Forums**: Reddit r/running often shares course files

### **File Quality Indicators**
- **Track Point Count**: 1000+ points for marathon = good resolution
- **Elevation Data**: Should have `<ele>` tags, not just lat/lon
- **File Size**: 500KB-5MB typical for marathon GPX
- **Smooth Profile**: Elevation should change gradually, not spike

---

**🏃‍♂️ READY TO GET REAL MARATHON DATA FLOWING!**

*Let's turn Runner Incline into the ultimate treadmill training platform!*