-- Sprint 3: Schema Changes for Treadmill Simulation
-- Run these SQL commands in the Supabase SQL Editor

-- Create the pace_segments table
CREATE TABLE public.pace_segments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id uuid REFERENCES public.courses(id) ON DELETE CASCADE NOT NULL,
  segment_index integer NOT NULL,
  distance_miles double precision NOT NULL,
  recommended_pace_seconds_per_mile integer NOT NULL, -- e.g., 412 for 6:52/mile
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.pace_segments ENABLE ROW LEVEL SECURITY;

-- RLS Policies (mirrors 'segments' table)
CREATE POLICY "Allow public to read pace segments for verified courses"
  ON public.pace_segments
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.courses 
      WHERE courses.id = pace_segments.course_id 
      AND courses.verified = true
    )
  );

CREATE POLICY "Allow service role to insert pace segments"
  ON public.pace_segments
  FOR INSERT
  TO service_role
  WITH CHECK (true);

-- Create indexes for performance
CREATE INDEX idx_pace_segments_course_id ON public.pace_segments(course_id);
CREATE INDEX idx_pace_segments_course_segment ON public.pace_segments(course_id, segment_index);

-- Example: Insert pace data for Boston Marathon (3:00:00 BQ strategy - 6:52/mile = 412 seconds)
-- Replace 'your-boston-course-id' with the actual UUID of Boston Marathon course
-- Uncomment and modify these lines after you have the actual course IDs:

-- INSERT INTO public.pace_segments (course_id, segment_index, distance_miles, recommended_pace_seconds_per_mile)
-- VALUES 
--   ('your-boston-course-id', 0, 0.0, 412),
--   ('your-boston-course-id', 1, 0.1, 412),
--   ('your-boston-course-id', 2, 0.2, 412),
--   ('your-boston-course-id', 3, 0.3, 412);
-- Continue for all segments...