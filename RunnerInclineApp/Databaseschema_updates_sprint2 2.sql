-- Sprint 2 Schema Updates: Authentication & User Ownership
-- Apply this to Supabase SQL Editor to fix RLS policy blocking course creation
-- Date: October 20, 2025

-- 1. Add created_by field to courses table (if not exists)
ALTER TABLE public.courses 
ADD COLUMN IF NOT EXISTS created_by uuid REFERENCES auth.users(id) ON DELETE SET NULL;

-- 2. Create index for performance
CREATE INDEX IF NOT EXISTS idx_courses_created_by ON public.courses(created_by);

-- 3. Enable RLS on courses table (if not already enabled)
ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;

-- 4. Drop existing policies to avoid conflicts
DROP POLICY IF EXISTS "Public read access to courses" ON public.courses;
DROP POLICY IF EXISTS "Authenticated users can create courses" ON public.courses;
DROP POLICY IF EXISTS "Users can update own courses" ON public.courses;

-- 5. Create new RLS policies

-- Allow public read access to all courses
CREATE POLICY "Public read access to courses"
  ON public.courses
  FOR SELECT
  USING (true);

-- Allow authenticated users to create courses
CREATE POLICY "Authenticated users can create courses"
  ON public.courses
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = created_by);

-- Allow users to update their own courses
CREATE POLICY "Users can update own courses"
  ON public.courses
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = created_by)
  WITH CHECK (auth.uid() = created_by);

-- 6. Enable RLS on segments table and create policies
ALTER TABLE public.segments ENABLE ROW LEVEL SECURITY;

-- Drop existing segment policies
DROP POLICY IF EXISTS "Public read access to segments" ON public.segments;
DROP POLICY IF EXISTS "System can manage segments" ON public.segments;

-- Allow public read access to segments
CREATE POLICY "Public read access to segments"
  ON public.segments
  FOR SELECT
  USING (true);

-- Allow system (service role) to manage segments for course processing
CREATE POLICY "System can manage segments"
  ON public.segments
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- Allow authenticated users to manage segments for their own courses
CREATE POLICY "Users can manage segments for own courses"
  ON public.segments
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.courses 
      WHERE courses.id = segments.course_id 
      AND courses.created_by = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.courses 
      WHERE courses.id = segments.course_id 
      AND courses.created_by = auth.uid()
    )
  );

-- 7. Update existing courses to have a default created_by (optional - for existing data)
-- UPDATE public.courses SET created_by = '00000000-0000-0000-0000-000000000000' 
-- WHERE created_by IS NULL;

-- 8. Grant necessary permissions
GRANT SELECT ON public.courses TO anon;
GRANT SELECT ON public.segments TO anon;
GRANT ALL ON public.courses TO authenticated;
GRANT ALL ON public.segments TO authenticated;

-- Success message
SELECT 'Sprint 2 schema updates applied successfully! RLS policies updated for authentication.' AS result;