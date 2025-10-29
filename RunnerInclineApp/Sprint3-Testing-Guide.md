# 🧪 Sprint 3 Testing Guide

## 🗂️ Prerequisites for Testing

### 1. Database Setup
First, run the SQL scripts in order:

1. **Run:** `schema-sprint3-changes.sql` (creates pace_segments table)
2. **Run:** `complete-boston-pace-setup.sql` (creates test data)

### 2. Xcode Color Assets
Add these colors to `Assets.xcassets` → `Colors`:

| Color Name | Hex Code | Usage |
|------------|----------|-------|
| ActionGreen | #34C759 | Primary actions, live data |
| OffBlack | #1C1C1E | Main background |
| DarkGray | #2C2C2E | Card backgrounds |
| LightText | #F2F2F7 | Primary text |
| MutedText | #98989D | Secondary text |
| UphillOrange | #FF9500 | Uphill gradients |
| DownhillCyan | #5AC8FA | Downhill gradients |

### 3. Required Imports
Make sure these files are added to your Xcode project:
- ✅ All `.swift` files we created
- ✅ Updated `CourseDetailView.swift`
- ✅ Updated `SupabaseService.swift`

---

## 🎯 Test Cases

### Test Case 1: Basic Flow (Happy Path)
**Objective:** Verify the complete user flow works end-to-end.

**Steps:**
1. Launch app and navigate to CourseListView
2. Find "Boston Marathon (Test)" course
3. Tap to open CourseDetailView
4. Verify "Start Run" button appears (only if course is verified and has segments)
5. Tap "Start Run"
6. Verify TreadmillRunView loads with course data

**Expected Results:**
- ✅ Loading screen appears briefly
- ✅ Live data shows: 0.0% incline, 6:52/mi pace, 0.00 mi distance
- ✅ Elevation chart displays with progress dot at start
- ✅ "Start Run" button is enabled and visible

### Test Case 2: Simulation Engine
**Objective:** Verify the timer-based simulation works correctly.

**Steps:**
1. In TreadmillRunView, tap "Start Run"
2. Watch the simulation for 30 seconds
3. Verify numbers are updating smoothly

**Expected Results:**
- ✅ Distance increments every 0.1 seconds (reaches ~0.30 mi after 30 seconds)
- ✅ Numbers use `.contentTransition(.numericText())` rolling animation
- ✅ Progress dot moves along the elevation chart
- ✅ "UP NEXT" section shows upcoming changes
- ✅ Current incline/pace update based on segment data

### Test Case 3: Run Controls
**Objective:** Verify pause/resume/end functionality.

**Steps:**
1. Start a run and let it progress to ~0.50 miles
2. Tap "Pause" - verify timer stops
3. Tap "Resume" - verify timer continues from where it left off
4. Tap "End Run" - verify returns to CourseDetailView

**Expected Results:**
- ✅ Pause button stops all updates
- ✅ Resume continues from exact same position
- ✅ End run resets distance to 0.00 and dismisses modal
- ✅ Button labels change appropriately (Start → Pause → Resume)

### Test Case 4: Minimize/Maximize UI
**Objective:** Verify the minimizable interface works.

**Steps:**
1. Start a run
2. Tap the minimize button (minus icon)
3. Verify compact header appears
4. Use quick controls in minimized view
5. Tap expand button to return to full view

**Expected Results:**
- ✅ Smooth animation between full and minimized states
- ✅ Minimized view shows current stats in one line
- ✅ Quick play/pause controls work in minimized mode
- ✅ Expand button returns to full interface

### Test Case 5: Data Loading & Error States
**Objective:** Verify proper handling of loading and empty states.

**Steps:**
1. Test with a course that has no segments
2. Test with a course that has no pace segments
3. Test with network connectivity issues

**Expected Results:**
- ✅ Loading spinner appears while fetching data
- ✅ "Start Run" button disabled if no segments
- ✅ Graceful fallback if pace segments missing
- ✅ Error messages logged to console

---

## 🚀 Performance Testing

### Memory & CPU
**Test:** Run simulation for 5+ minutes (simulates 50+ miles)
- ✅ Memory usage should remain stable
- ✅ Timer should not leak or accumulate
- ✅ UI should remain responsive

### Animation Smoothness
**Test:** Watch numeric transitions during rapid changes
- ✅ `.contentTransition(.numericText())` should be smooth
- ✅ Chart progress dot should animate fluidly
- ✅ No frame drops or stuttering

---

## 🐛 Common Issues & Solutions

### Issue: "Start Run" Button Not Appearing
**Cause:** Course not verified OR no segments data
**Solution:** Run this SQL to verify your test data:
```sql
SELECT c.name, c.verified, COUNT(s.id) as segment_count 
FROM courses c 
LEFT JOIN segments s ON c.id = s.course_id 
WHERE c.name ILIKE '%boston%';
```

### Issue: Colors Not Working
**Cause:** Color assets not added to Xcode
**Solution:** Add all colors from `ColorAssets.swift` to Assets.xcassets

### Issue: Simulation Too Fast/Slow
**Cause:** Timer increment value
**Solution:** Modify `incrementPerSecond` in `TreadmillRunViewModel.swift`:
- Current: 0.01 (1 mile per 10 seconds)
- Slower: 0.005 (1 mile per 20 seconds)
- Faster: 0.02 (1 mile per 5 seconds)

### Issue: Chart Not Displaying
**Cause:** No segments data OR missing Charts import
**Solution:** 
1. Verify segments data exists in database
2. Ensure `import Charts` is in LiveElevationChartView.swift

---

## 📊 Success Criteria Checklist

- [ ] **Schema:** pace_segments table created successfully
- [ ] **Data:** Boston Marathon has pace strategy data (262 segments)
- [ ] **Colors:** All 7 design system colors added to Xcode
- [ ] **Flow:** CourseDetailView → TreadmillRunView works seamlessly
- [ ] **Simulation:** Timer-based progression (1 mile per 10 seconds)
- [ ] **UI:** Glassmorphism styling matches design document
- [ ] **Animations:** Smooth numeric transitions and chart progress
- [ ] **Controls:** Start/Pause/Resume/End all functional
- [ ] **Minimize:** Collapsible UI works without issues
- [ ] **Performance:** Stable memory usage during long runs

---

## 🎯 Ready for Sprint 4

Once all tests pass, you're ready to move on to Sprint 4:
- Refactor CourseListView with new design system
- Add `.matchedGeometryEffect` transitions
- Hide user upload functionality
- Plan watchOS integration

**The "killer feature" is now live and ready for users!** 🚀