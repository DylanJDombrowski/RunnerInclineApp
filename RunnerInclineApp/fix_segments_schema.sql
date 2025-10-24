-- Fix segments table schema cache issue
-- Run this in your Supabase SQL Editor

-- Drop the existing table (this will clear the cache)
DROP TABLE IF EXISTS public.segments CASCADE;

-- Recreate the segments table
CREATE TABLE public.segments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id uuid REFERENCES public.courses(id) ON DELETE CASCADE NOT NULL,
  segment_index integer NOT NULL,
  distance_miles double precision NOT NULL,
  elevation_ft double precision NOT NULL,
  grade_percent double precision,
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.segments ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Allow public to read segments for verified courses"
  ON public.segments
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.courses 
      WHERE courses.id = segments.course_id 
      AND courses.verified = true
    )
  );

CREATE POLICY "Allow users to read segments for own courses"
  ON public.segments
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.courses 
      WHERE courses.id = segments.course_id 
      AND courses.created_by = auth.uid()
    )
  );

CREATE POLICY "Allow service role to insert segments"
  ON public.segments
  FOR INSERT
  TO service_role
  WITH CHECK (true);

-- Create indexes
CREATE INDEX idx_segments_course_id ON public.segments(course_id);
CREATE INDEX idx_segments_course_segment ON public.segments(course_id, segment_index);

-- Force schema refresh by granting permissions
GRANT ALL ON public.segments TO service_role;
GRANT SELECT ON public.segments TO authenticated;
GRANT SELECT ON public.segments TO anon;