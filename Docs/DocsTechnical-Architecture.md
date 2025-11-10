# ⚙️ Technical Architecture Documentation

## 🏗️ **System Overview**

The RunnerInclineApp is built as a modern iOS application using SwiftUI with a focus on real-time data visualization and simulation. The architecture follows MVVM patterns with reactive data binding and async/await for network operations.

---

## 🗂️ **Project Structure**

```
RunnerInclineApp/
├── Models/
│   ├── Course.swift              # Core course data model
│   ├── Segment.swift             # Elevation segment model  
│   ├── PaceSegment.swift         # Pace strategy model (NEW)
│   └── User models...            # Authentication models
├── Views/
│   ├── CourseListView.swift      # Home screen course browser
│   ├── CourseDetailView.swift    # Course details + "Start Run" 
│   ├── TreadmillRunView.swift    # Main simulation interface (NEW)
│   ├── LiveTreadmillDataView.swift   # Data display module (NEW)
│   ├── LiveElevationChartView.swift  # Interactive chart (NEW)  
│   └── Supporting views...
├── ViewModels/
│   ├── CourseViewModel.swift     # Course data management
│   ├── SegmentViewModel.swift    # Elevation data fetching
│   ├── TreadmillRunViewModel.swift   # Simulation engine (NEW)
│   └── Authentication...
├── Services/
│   ├── SupabaseService.swift     # Database & storage operations
│   └── AuthenticationManager.swift
├── Assets.xcassets/
│   └── Colors/                   # Design system color definitions
└── Supporting Files/
    ├── Info.plist               # Supabase configuration  
    └── App configuration...
```

---

## 🎯 **Core Architecture Patterns**

### **1. MVVM with Combine**
- **ViewModels** manage business logic and data fetching
- **@Published** properties for reactive UI updates  
- **@StateObject** and **@ObservedObject** for SwiftUI integration
- **async/await** for modern concurrency patterns

### **2. Single Source of Truth**
- **Supabase** as primary database for all course/segment data
- **Local state management** in ViewModels for UI performance
- **@Published** properties trigger automatic UI updates
- **Error handling** with graceful fallbacks and user messaging

### **3. Composition over Inheritance**
- **Modular SwiftUI components** for reusability
- **Protocol-oriented networking** for testability  
- **Dependency injection** for service layer abstraction
- **ViewBuilder patterns** for flexible UI composition

---

## 🗄️ **Data Architecture**

### **Database Schema (Supabase/PostgreSQL)**

#### **Core Tables**
```sql
-- Course metadata and verification status
courses (
  id uuid PRIMARY KEY,
  name text NOT NULL,
  city text,
  distance_miles double precision,
  total_elevation_gain_ft double precision,
  verified boolean DEFAULT false,
  created_by uuid REFERENCES auth.users(id),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
)

-- Elevation profile data (0.1 mile intervals)  
segments (
  id uuid PRIMARY KEY,
  course_id uuid REFERENCES courses(id) ON DELETE CASCADE,
  segment_index integer NOT NULL,
  distance_miles double precision NOT NULL,
  elevation_ft double precision NOT NULL,  
  grade_percent double precision,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
)

-- NEW: Pace strategy data for training plans
pace_segments (
  id uuid PRIMARY KEY,
  course_id uuid REFERENCES courses(id) ON DELETE CASCADE,
  segment_index integer NOT NULL,
  distance_miles double precision NOT NULL,
  recommended_pace_seconds_per_mile integer NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
)
```

#### **Row Level Security (RLS)**
- Public read access for all `verified = true` courses.
- Admin-only write access (handled via a secure admin user account).
- Authenticated user read access for their "My Library" (future).
- **Proper indexing** on course_id and segment_index

### **Swift Data Models**

#### **Course Model**
```swift
struct Course: Identifiable, Codable {
    let id: UUID
    let name: String
    let city: String?
    let distance_miles: Double?        // Optional for incomplete data
    let total_elevation_gain_ft: Double?
    let verified: Bool                 // Controls "Start Run" visibility  
    let created_by: UUID?
    let created_at: Date?              // Optional for RLS compatibility
    let updated_at: Date?
}
```

#### **Segment Model**
```swift  
struct Segment: Identifiable, Codable {
    let id: UUID
    let course_id: UUID
    let segment_index: Int             // Ordered position (0, 1, 2...)
    let distance_miles: Double         // Cumulative distance
    let elevation_ft: Double           // Absolute elevation
    let grade_percent: Double?         // Calculated incline percentage
    let created_at: Date?
    let updated_at: Date?
}
```

#### **PaceSegment Model (NEW)**
```swift
struct PaceSegment: Identifiable, Codable {
    let id: UUID  
    let course_id: UUID
    let segment_index: Int
    let distance_miles: Double
    let recommended_pace_seconds_per_mile: Int  // e.g., 412 = 6:52/mile
    
    // Computed properties for UI display
    var formattedPace: String          // "6:52"
    var paceMinutes: Double            // 6.87
}
```

---

## 🚀 **Core Simulation Engine**

### **TreadmillRunViewModel Architecture**

#### **Key Responsibilities**
1. **Timer Management**: Precise 0.1-second intervals for smooth animation
2. **Segment Transitions**: Automatic incline/pace updates based on distance
3. **State Management**: Run/pause/resume/end control logic
4. **Data Fetching**: Async loading of segments and pace strategies
5. **Performance Optimization**: Efficient array lookups and minimal allocations

#### **Critical Implementation Details**
```swift
class TreadmillRunViewModel: ObservableObject {
    // Published properties trigger SwiftUI updates
    @Published var currentDistance: Double = 0.0
    @Published var currentIncline: Double = 0.0
    @Published var currentPace: Double = 420  // 7:00/mile default
    @Published var nextIncline: Double = 0.0
    @Published var nextPace: Double = 420
    @Published var distanceToNextChange: Double = 0.0
    
    // Timer configuration for smooth animation
    private let incrementPerSecond: Double = 0.1 / 10  // 1 mile per 10 seconds
    private var timer: Timer?
    
    // Efficient data lookup methods
    private func findSegmentForDistance(_ distance: Double) -> Segment? {
        return segments.last { $0.distance_miles <= distance }
    }
}
```

#### **Performance Characteristics**
- **Update Frequency**: 10 Hz (0.1 second intervals)
- **Simulation Speed**: 1 mile per 10 seconds (configurable)
- **Memory Usage**: Stable during long runs (proper timer cleanup)
- **CPU Impact**: Minimal (efficient array operations)
- **Animation Smoothness**: 60 FPS with `.contentTransition(.numericText())`

---

## 📊 **Data Visualization Architecture**

### **Apple Charts Integration**

#### **LiveElevationChartView Implementation**
```swift
Chart {
    // Elevation area fill with gradient
    ForEach(segments) { segment in
        AreaMark(x: .value("Distance", segment.distance_miles),
                y: .value("Elevation", segment.elevation_ft))
            .foregroundStyle(elevationGradient)
    }
    
    // Elevation line outline
    ForEach(segments) { segment in  
        LineMark(x: .value("Distance", segment.distance_miles),
                y: .value("Elevation", segment.elevation_ft))
            .foregroundStyle(Color("ActionGreen"))
    }
    
    // REAL-TIME: Live progress indicators
    if currentDistance > 0 {
        RuleMark(x: .value("Current", currentDistance))     // Vertical line
        PointMark(x: .value("Current", currentDistance),    // Position dot
                 y: .value("Elevation", currentElevation))
    }
}
.animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentDistance)
```

#### **Chart Performance Optimizations**
- **Efficient rendering**: Direct ForEach over segments (no transforms)
- **Smooth animations**: Spring physics with optimized parameters
- **Memory management**: No retained chart state between updates  
- **Responsive design**: Proper axis scaling and responsive layouts

---

## 🎨 **Design System Implementation**

### **Glassmorphism Components**

#### **Core Visual Elements**
```swift
// Standard glassmorphism background
.background {
    ZStack {
        Color("DarkGray")                    // Base color
        Color.clear.background(.ultraThinMaterial)  // Glass effect
    }
    .clipShape(RoundedRectangle(cornerRadius: 16))
    .overlay {
        RoundedRectangle(cornerRadius: 16)
            .stroke(Color.white.opacity(0.2), lineWidth: 1)  // Subtle border
    }
}
```

#### **Typography System**
- **DataDisplay**: `.font(.system(.title, design: .monospaced)).fontWeight(.bold)`
- **Numeric Transitions**: `.contentTransition(.numericText())` for smooth updates
- **Hierarchy**: Clear information hierarchy with consistent font scaling
- **Accessibility**: Supports Dynamic Type and high contrast modes

#### **Color Strategy**
- **Dark-mode first**: Optimized for fitness/gym environments
- **High contrast**: Excellent readability during exercise
- **Semantic colors**: Green for current, Orange for uphill, Cyan for downhill
- **Accessibility compliance**: WCAG AA contrast ratios

---

## 🔌 **Network Layer Architecture**

### **SupabaseService Design**

#### **Connection Management**
```swift
final class SupabaseService {
    static let shared = SupabaseService()  // Singleton pattern
    let client: SupabaseClient
    
    private init() {
        // Configuration from Info.plist for security
        client = SupabaseClient(supabaseURL: url, supabaseKey: key)
    }
}
```

#### **Data Fetching Patterns**
```swift
// Generic async/await pattern with error handling
func fetchSegments(for courseId: UUID) async throws -> [Segment] {
    let response: [Segment] = try await client
        .from("segments")
        .select()
        .eq("course_id", value: courseId)
        .order("segment_index", ascending: true)
        .execute()
        .value
    return response
}
```

#### **Error Handling Strategy**
- **Graceful degradation**: App functions with limited data
- **User feedback**: Clear error messages for network issues
- **Retry logic**: Automatic retry for transient failures
- **Offline support**: Cache critical data locally

---

## 🧪 **Testing Architecture**

### **Test Coverage Strategy**

#### **Unit Tests**
- **ViewModel logic**: State transitions, calculations, data processing
- **Model validation**: JSON decoding, computed properties  
- **Service layer**: Network requests, error handling
- **Utilities**: Date formatting, pace calculations, distance math

#### **Integration Tests**  
- **Database queries**: Supabase integration with test data
- **Chart rendering**: Apple Charts with sample datasets
- **Timer accuracy**: Simulation engine precision testing
- **Memory leaks**: Long-running simulation stability

#### **UI Tests**
- **Complete user flow**: Course selection → simulation → completion  
- **Accessibility**: VoiceOver navigation and element identification
- **Performance**: Frame rate during animation, battery usage
- **Edge cases**: Network failures, missing data, device rotation

### **Quality Assurance Process**
1. **Automated testing**: CI/CD pipeline with comprehensive test suite
2. **Manual testing**: Device testing across iPhone models and iOS versions  
3. **Performance profiling**: Instruments analysis for memory/CPU usage
4. **Accessibility audit**: VoiceOver and assistive technology compatibility

---

## 🔒 **Security & Privacy**

### **Data Protection**
- **Supabase RLS**: Row-level security prevents unauthorized data access
- **No local storage**: Sensitive data remains on secure backend  
- **Minimal data collection**: Only essential user information
- **Privacy by design**: Optional features, clear consent mechanisms

### **Authentication Flow**
- **Supabase Auth**: Secure user authentication with JWT tokens
- **Session management**: Automatic token refresh and secure storage
- **Guest access**: Limited functionality without account creation
- **Data ownership**: Users control their uploaded content

---

## 📈 **Performance Considerations**

### **Optimization Strategies**
1. **Lazy loading**: Load course data on-demand
2. **Memory management**: Proper cleanup of timers and observations
3. **Image optimization**: Efficient asset delivery and caching
4. **Background processing**: Non-blocking network operations
5. **Battery optimization**: Efficient timer usage, minimal background activity

### **Scalability Design**
- **Database indexing**: Optimized queries for large course catalogs
- **CDN integration**: Fast asset delivery globally
- **Modular architecture**: Easy to add new features without coupling
- **Horizontal scaling**: Supabase handles increased user load automatically

---

*This technical documentation provides a comprehensive understanding of the system architecture, enabling efficient development and maintenance as the project scales.*
