# Quick Test Guide - Start of Next Session

## ✅ **Immediate Actions Required**

### **1. Test Upload with Fixed Schema (2 minutes)**
```
1. Build and run app
2. Go to "My Courses" tab
3. Tap "+" → "Use Test GPX" 
4. Fill course name, tap "Upload"
5. Should complete successfully
6. Tap on the course → Should see elevation chart with 15 segments
```

### **2. Verify Database (1 minute)**  
```
1. Open Supabase Dashboard
2. Check "courses" table → Should see your test course
3. Check "segments" table → Should see 15 segments with:
   - course_id matching your course
   - distance_miles values
   - elevation_ft values  
   - grade_percent values
```

### **3. Test Navigation (1 minute)**
```
1. Check all 3 tabs work: Home, My Courses, Profile
2. Profile tab should show your Apple ID email
3. Course should appear with "Pending" orange badge
4. Home tab should show verified courses (if any)
```

## 🎯 **Expected Results**
- ✅ Upload completes without errors
- ✅ Course appears with elevation chart
- ✅ 15 segments visible in database
- ✅ All navigation working smoothly

## 🔧 **If Something Breaks**
1. **Upload fails**: Check Supabase Function logs for errors
2. **No elevation chart**: Verify segments table has data
3. **App won't build**: Check import statements in updated files

## 📋 **Files Updated This Session**
- `Segment.swift` - Updated to match database schema
- `SegmentViewModel.swift` - Fixed column names  
- `CourseDetailView.swift` - Updated to use new segment fields
- `SupabaseService.swift` - Fixed to return real database IDs

## 🚀 **You're Ready for Sprint 3!**

The core upload pipeline is working end-to-end. Time to add polish and advanced features!