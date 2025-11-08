# 🛠️ Development Setup & Maintenance Guide

## 🚀 **Quick Start Guide**

### **Prerequisites**
- **Xcode 15+** with iOS 17+ deployment target
- **Supabase account** with PostgreSQL database  
- **Apple Developer account** for device testing
- **Swift Package Manager** for dependency management

### **Initial Setup**
1. **Clone repository** and open in Xcode
2. **Configure Supabase** credentials in Info.plist:
   ```xml
   <key>SUPABASE_URL</key>
   <string>https://your-project.supabase.co</string>
   <key>SUPABASE_ANON_KEY</key> 
   <string>your-anon-key-here</string>
   ```
3. **Run database migrations** from `/repo/Docs/Database-Setup/`
4. **Add color assets** to Assets.xcassets (see Color Setup section)
5. **Build and run** - app should connect to Supabase successfully

---

## 🗄️ **Database Setup & Maintenance**

### **Initial Schema Setup**
Run these SQL scripts in Supabase SQL Editor in order:

#### **1. Core Tables** 
```sql
-- Already exists in your project
-- courses, segments tables established
```

#### **2. Sprint 3 Additions**
```sql
-- From: schema-sprint3-changes.sql
-- Creates pace_segments table with proper RLS policies
-- Adds performance indexes for efficient queries
```

### **Test Data Creation**
```sql
-- From: create-test-segments.sql  
-- Creates sample elevation data for Boston Marathon
-- Replace 'YOUR_BOSTON_COURSE_ID_HERE' with actual UUID

-- From: create-test-pace-segments.sql
-- Creates pace strategy data (6:52/mile for 3:00:00 BQ)
-- Essential for "Start Run" button to appear
```

### **Database Maintenance Tasks**

#### **Weekly Monitoring**
- **Performance metrics**: Query execution times, connection counts
- **Storage usage**: Monitor database size growth
- **Error logs**: Check Supabase logs for failed operations
- **User activity**: Track course usage and popular segments

#### **Monthly Maintenance**
- **Index optimization**: Analyze query performance and add indexes as needed
- **Data cleanup**: Remove unused test data and orphaned records  
- **Backup verification**: Ensure automated backups are functioning
- **RLS policy review**: Audit row-level security for any gaps

#### **Quarterly Updates**
- **Schema migrations**: Plan and execute new feature database changes
- **Performance tuning**: Optimize slow queries and database configuration
- **Security review**: Update authentication policies and access controls
- **Capacity planning**: Monitor growth trends and scale resources

---

## 🎨 **Design System Maintenance**

### **Color Asset Setup**
In Xcode Assets.xcassets, create these color sets:

| Color Name | Hex Value | Usage |
|------------|-----------|--------|
| **ActionGreen** | `#34C759` | Primary buttons, active states, live data |
| **OffBlack** | `#1C1C1E` | Main background color |
| **AppDarkGray** | `#2C2C2E` | Card backgrounds (renamed to avoid UIKit conflict) |
| **AppLightText** | `#F2F2F7` | Primary text on dark backgrounds |
| **MutedText** | `#98989D` | Secondary text and captions |
| **UphillOrange** | `#FF9500` | Uphill elevation indicators |
| **DownhillCyan** | `#5AC8FA` | Downhill elevation indicators |

#### **Color Asset Configuration**
- Set **both "Any Appearance" and "Dark Appearance"** to same values
- This ensures consistency across light/dark mode
- Use descriptive names to avoid UIKit system color conflicts

### **Typography Guidelines**
```swift
// Data Display (for all live metrics)
.font(.system(.title, design: .monospaced))
.fontWeight(.bold)
.contentTransition(.numericText())  // Smooth number updates

// Section Headers
.font(.headline)
.fontWeight(.medium)

// Supporting Information
.font(.caption)
.foregroundColor(Color("MutedText"))
```

### **Component Library Standards**
- **Glassmorphism cards**: Use `.ultraThinMaterial` + white border
- **Button states**: Include pressed animations with `scaleEffect(0.98)`
- **Corner radius**: 16px for cards, 10px for buttons
- **Spacing**: 8-point grid system (8, 16, 24, 32px)

---

## 🧪 **Testing & Quality Assurance**

### **Development Testing Workflow**

#### **Daily Testing Checklist**
- [ ] **App launch**: Successful Supabase connection
- [ ] **Course loading**: 12+ courses appear in list view
- [ ] **Course detail**: Navigation and data display work
- [ ] **Segment loading**: Debug output shows "✅ Successfully loaded X segments"
- [ ] **Start Run button**: Visible on verified courses with segments
- [ ] **Treadmill simulation**: Smooth progression and data updates

#### **Weekly Regression Testing**
- [ ] **Complete user flow**: Course selection → simulation → completion
- [ ] **Error handling**: Network disconnection, missing data scenarios
- [ ] **Performance**: Memory usage stable during 5+ minute runs
- [ ] **UI consistency**: All screens follow design system
- [ ] **Accessibility**: VoiceOver navigation works properly

#### **Pre-Release Testing**
- [ ] **Device coverage**: Test on iPhone SE, standard, Plus/Max sizes
- [ ] **iOS versions**: Minimum supported version compatibility
- [ ] **Stress testing**: Multiple course switches, long simulation runs
- [ ] **Battery impact**: Monitor energy usage during active simulation
- [ ] **App Store guidelines**: Content, functionality, performance compliance

### **Debugging Tools & Techniques**

#### **Common Issues & Solutions**
```swift
// Issue: "✅ Loaded 0 segments" despite database having data
// Solution: Check Segment model fields match database schema
// Enable debug logging in SegmentViewModel.fetchSegments()

// Issue: "No color named 'ActionGreen' found"  
// Solution: Verify color assets added to Assets.xcassets
// Use Color.green temporarily for immediate testing

// Issue: TreadmillRunView text invisible in dark mode
// Solution: Ensure color assets have both light/dark appearance set
// Check color naming conflicts with UIKit system colors

// Issue: Chart rendering errors or crashes
// Solution: Verify segments array has valid data before rendering
// Use simplified chart configuration if complex features fail
```

#### **Performance Monitoring**
```swift
// Add to TreadmillRunViewModel for performance tracking
private var updateCount = 0
private func updateRunProgress() {
    updateCount += 1
    if updateCount % 100 == 0 {  // Log every 10 seconds
        print("📊 Performance: \(updateCount) updates, distance: \(currentDistance)")
        print("📊 Memory usage: \(ProcessInfo.processInfo.physicalMemory / 1024 / 1024) MB")
    }
    // ... rest of update logic
}
```

---

## 🔧 **Code Architecture Guidelines**

### **File Organization Standards**
```
Views/
├── Core/                    # Main app screens
│   ├── CourseListView.swift
│   ├── CourseDetailView.swift  
│   └── TreadmillRunView.swift
├── Components/              # Reusable UI components
│   ├── LiveTreadmillDataView.swift
│   ├── LiveElevationChartView.swift
│   └── Shared components...
└── Supporting/              # Utility views
    ├── Authentication/
    └── Settings/

ViewModels/
├── CourseViewModel.swift    # Data management
├── SegmentViewModel.swift   # Elevation data
├── TreadmillRunViewModel.swift  # Simulation engine
└── Supporting ViewModels...

Models/
├── Course.swift             # Core data models
├── Segment.swift
├── PaceSegment.swift        # Sprint 3 addition
└── User models...
```

### **Coding Standards**

#### **SwiftUI Best Practices**
```swift
// ✅ Good: Clear, focused views
struct LiveTreadmillDataView: View {
    @ObservedObject var viewModel: TreadmillRunViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            upNextSection
            currentDataSection  
            progressSection
        }
        .glassmorphismBackground()  // Custom modifier
    }
}

// ✅ Good: Extract complex logic to computed properties
private var upNextSection: some View {
    VStack(alignment: .leading, spacing: 8) {
        Text("UP NEXT").font(.headline)
        // ... section content
    }
}

// ❌ Avoid: Massive body with nested logic
```

#### **ViewModel Patterns**
```swift
// ✅ Good: Clear responsibilities and error handling
@MainActor
final class TreadmillRunViewModel: ObservableObject {
    @Published var currentDistance: Double = 0.0
    @Published var isRunning = false
    
    func startRun() {
        guard !segments.isEmpty else { return }
        isRunning = true
        startTimer()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            Task { @MainActor in
                self.updateRunProgress()
            }
        }
    }
}
```

#### **Error Handling Standards**
```swift
// ✅ Good: Comprehensive error handling with user feedback
func fetchSegments(for courseId: UUID) async {
    isLoading = true
    do {
        let response: [Segment] = try await service.fetchSegments(courseId)
        self.segments = response
        print("✅ Loaded \(response.count) segments")
    } catch {
        print("❌ Error loading segments: \(error)")
        self.segments = []
        // Show user-friendly error message
        self.errorMessage = "Unable to load course data. Please try again."
    }
    isLoading = false
}
```

---

## 📱 **Deployment & Release Management**

### **Pre-Release Checklist**
- [ ] **Version number**: Update CFBundleShortVersionString
- [ ] **Build number**: Increment CFBundleVersion
- [ ] **App Store assets**: Screenshots, descriptions, keywords updated
- [ ] **TestFlight beta**: Distribute to internal testers
- [ ] **Performance testing**: Memory leaks, battery usage validation
- [ ] **Accessibility audit**: VoiceOver, Dynamic Type, high contrast

### **App Store Optimization**
#### **Key Features to Highlight**
1. **Real-world race simulation** with accurate elevation profiles
2. **Professional pacing strategies** for marathon training  
3. **Live coaching prompts** during treadmill workouts
4. **Interactive visualization** with Apple Charts
5. **Curated course library** featuring major marathons

#### **Screenshot Strategy**
- **Hero shot**: TreadmillRunView during active simulation
- **Course browser**: Showing verified marathons (Boston, NYC, etc.)
- **Elevation profile**: Detailed chart with progress indicator
- **Data dashboard**: Live metrics and pacing information  
- **Dark mode**: Emphasize gym-friendly interface

### **Release Notes Template**
```
🏃‍♂️ What's New in RunnerInclineApp v1.3

✨ NEW FEATURES
• Real-time treadmill simulation with accurate pacing
• Interactive elevation charts with live progress
• Boston Marathon and major race courses added

🔧 IMPROVEMENTS  
• Enhanced dark mode for gym environments
• Smoother animations and transitions
• Better error handling and offline support

🐛 BUG FIXES
• Fixed elevation data loading issues
• Improved chart rendering performance
• Resolved color display problems

Ready to transform your treadmill training? Start your virtual Boston Marathon today!
```

---

## 🔄 **Continuous Integration & Deployment**

### **Automated Testing Pipeline**
```yaml
# Example GitHub Actions workflow
name: iOS CI/CD
on: [push, pull_request]

jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build and Test
        run: |
          xcodebuild test -scheme RunnerInclineApp \
                         -destination 'platform=iOS Simulator,name=iPhone 14' \
                         -resultBundlePath TestResults
      - name: Performance Tests
        run: |
          # Memory leak detection
          # Battery usage profiling  
          # Frame rate validation
```

### **Code Quality Gates**
- **Unit test coverage**: Minimum 80% for core functionality
- **SwiftLint compliance**: No warnings or errors
- **Performance benchmarks**: Memory usage, battery impact within limits
- **Accessibility compliance**: All interactive elements properly labeled

---

## 📞 **Support & Troubleshooting**

### **Common User Issues**

#### **"No courses appear on home screen"**
- **Check**: Supabase connection (network logs)
- **Verify**: Database has verified courses with `verified = true`
- **Test**: Run CourseViewModel.fetchCourses() manually

#### **"Start Run button missing on course detail"**  
- **Check**: Course has `verified = true` AND segments exist
- **Debug**: Enable SegmentViewModel logging to confirm data loading
- **Fix**: Ensure segments table has data for the course_id

#### **"Treadmill simulation freezes or crashes"**
- **Monitor**: Memory usage during simulation (Xcode Instruments)
- **Check**: Timer cleanup in TreadmillRunViewModel.deinit
- **Test**: Run simulation for extended periods (10+ minutes)

#### **"Colors appear wrong or missing"**
- **Verify**: All color assets added to Assets.xcassets  
- **Check**: Both light/dark appearance values set
- **Fix**: Rename conflicting colors (DarkGray → AppDarkGray)

### **Technical Support Process**
1. **Gather information**: iOS version, device model, steps to reproduce
2. **Check logs**: Console output, crash reports, network requests
3. **Reproduce locally**: Use same device/iOS version when possible  
4. **Provide fix**: Code changes, configuration updates, or workarounds
5. **Follow up**: Confirm resolution and document solution

---

*This development guide should enable smooth ongoing development and maintenance of the RunnerInclineApp codebase.*