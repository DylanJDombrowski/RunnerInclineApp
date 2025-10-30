-- Create pace segments for Boston Marathon
-- Run this AFTER creating elevation segments

-- Replace 'YOUR_BOSTON_COURSE_ID_HERE' with actual UUID
INSERT INTO public.pace_segments (course_id, segment_index, distance_miles, recommended_pace_seconds_per_mile)
VALUES 
  ('YOUR_BOSTON_COURSE_ID_HERE', 0, 0.0, 412), -- 6:52/mile
  ('YOUR_BOSTON_COURSE_ID_HERE', 1, 1.0, 412),
  ('YOUR_BOSTON_COURSE_ID_HERE', 2, 2.0, 412),
  ('YOUR_BOSTON_COURSE_ID_HERE', 3, 3.0, 412),
  ('YOUR_BOSTON_COURSE_ID_HERE', 4, 4.0, 412),
  ('YOUR_BOSTON_COURSE_ID_HERE', 5, 5.0, 412),
  ('YOUR_BOSTON_COURSE_ID_HERE', 6, 6.0, 412);

-- Verify pace segments:
SELECT ps.*, c.name 
FROM pace_segments ps 
JOIN courses c ON ps.course_id = c.id 
WHERE c.name ILIKE '%boston%'
ORDER BY ps.segment_index;