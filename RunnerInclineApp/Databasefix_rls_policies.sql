-- Fix RLS policies for courses table
-- This should be run in your Supabase SQL editor

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can manage own rows" ON public.courses;
DROP POLICY IF EXISTS "Allow public read" ON public.courses;
DROP POLICY IF EXISTS "Users can view own courses" ON public.courses;
DROP POLICY IF EXISTS "Users can create courses" ON public.courses;

-- Create comprehensive policies
CREATE POLICY "Public can read verified courses"
  ON public.courses
  FOR SELECT
  USING (verified = true);

CREATE POLICY "Users can read own courses"
  ON public.courses
  FOR SELECT
  TO authenticated
  USING (auth.uid() = created_by);

CREATE POLICY "Users can create courses"
  ON public.courses
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Users can update own courses"
  ON public.courses
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = created_by)
  WITH CHECK (auth.uid() = created_by);