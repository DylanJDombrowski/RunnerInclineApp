-- Complete SQL Script for Sprint 3 Treadmill Simulation
-- Run this in Supabase SQL Editor

-- Step 1: Create the pace_segments table (run the existing schema first)
-- (This should already be done from schema-sprint3-changes.sql)

-- Step 2: Insert a sample Boston Marathon course if it doesn't exist
-- This creates a test course for development
INSERT INTO public.courses (id, name, city, distance_miles, total_elevation_gain_ft, verified, created_by)
VALUES (
  gen_random_uuid(),
  'Boston Marathon (Test)',
  'Boston, MA',
  26.2,
  500.0,
  true,
  NULL
) ON CONFLICT DO NOTHING;

-- Step 3: Get the Boston Marathon course ID for pace data
-- You'll need to replace this UUID with your actual Boston Marathon course ID
-- To find it, run: SELECT id, name FROM public.courses WHERE name ILIKE '%boston%';

-- Step 4: Complete pace strategy for Boston Marathon
-- This creates a comprehensive 3:00:00 BQ strategy (6:52/mile = 412 seconds per mile)
-- Assuming your Boston Marathon course ID - replace 'your-actual-boston-course-id' with the real UUID

DO $$
DECLARE
    boston_course_id uuid;
    i integer;
    current_distance numeric;
    pace_seconds integer := 412; -- 6:52/mile for 3:00:00 marathon
BEGIN
    -- Find the Boston Marathon course ID
    SELECT id INTO boston_course_id 
    FROM public.courses 
    WHERE name ILIKE '%boston%' 
    AND verified = true 
    LIMIT 1;
    
    IF boston_course_id IS NULL THEN
        RAISE EXCEPTION 'No Boston Marathon course found. Please create one first.';
    END IF;
    
    RAISE NOTICE 'Using Boston Marathon course ID: %', boston_course_id;
    
    -- Insert pace segments for every 0.1 mile up to 26.2 miles
    FOR i IN 0..261 LOOP
        current_distance := i * 0.1;
        
        INSERT INTO public.pace_segments (
            course_id, 
            segment_index, 
            distance_miles, 
            recommended_pace_seconds_per_mile
        ) VALUES (
            boston_course_id,
            i,
            current_distance,
            pace_seconds
        ) ON CONFLICT DO NOTHING;
    END LOOP;
    
    RAISE NOTICE 'Inserted pace segments for Boston Marathon: % segments', i+1;
END $$;

-- Step 5: Verify the data was inserted correctly
SELECT 
    c.name as course_name,
    COUNT(ps.*) as pace_segments_count,
    MIN(ps.distance_miles) as min_distance,
    MAX(ps.distance_miles) as max_distance,
    ps.recommended_pace_seconds_per_mile as pace_seconds
FROM public.courses c
LEFT JOIN public.pace_segments ps ON c.id = ps.course_id
WHERE c.name ILIKE '%boston%'
GROUP BY c.name, ps.recommended_pace_seconds_per_mile
ORDER BY c.name;

-- Step 6: Sample query to test the data
-- This shows what the TreadmillRunViewModel will fetch
SELECT 
    ps.segment_index,
    ps.distance_miles,
    ps.recommended_pace_seconds_per_mile,
    CONCAT(
        (ps.recommended_pace_seconds_per_mile / 60)::text, 
        ':', 
        LPAD((ps.recommended_pace_seconds_per_mile % 60)::text, 2, '0')
    ) as formatted_pace
FROM public.pace_segments ps
JOIN public.courses c ON ps.course_id = c.id
WHERE c.name ILIKE '%boston%'
ORDER BY ps.segment_index
LIMIT 10;