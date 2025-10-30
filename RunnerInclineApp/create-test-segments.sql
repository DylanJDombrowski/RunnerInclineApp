-- Create test segments for Boston Marathon
-- Run this AFTER replacing 'your-boston-course-id' with actual UUID

-- First, find your Boston Marathon course ID:
SELECT id, name FROM courses WHERE name ILIKE '%boston%';

-- Then replace the UUID below and run:
INSERT INTO public.segments (course_id, segment_index, distance_miles, elevation_ft, grade_percent)
VALUES 
  ('YOUR_BOSTON_COURSE_ID_HERE', 0, 0.0, 100, 0.0),
  ('YOUR_BOSTON_COURSE_ID_HERE', 1, 1.0, 120, 2.0),
  ('YOUR_BOSTON_COURSE_ID_HERE', 2, 2.0, 150, 3.0),
  ('YOUR_BOSTON_COURSE_ID_HERE', 3, 3.0, 200, 5.0),
  ('YOUR_BOSTON_COURSE_ID_HERE', 4, 4.0, 180, -2.0),
  ('YOUR_BOSTON_COURSE_ID_HERE', 5, 5.0, 160, -1.0),
  ('YOUR_BOSTON_COURSE_ID_HERE', 6, 6.0, 140, 0.5);

-- Verify the segments were created:
SELECT s.*, c.name 
FROM segments s 
JOIN courses c ON s.course_id = c.id 
WHERE c.name ILIKE '%boston%'
ORDER BY s.segment_index;