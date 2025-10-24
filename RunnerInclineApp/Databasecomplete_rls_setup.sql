-- Complete RLS Policy Setup for Courses Table
-- Run this in your Supabase SQL Editor

-- First, ensure RLS is enabled
ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;

-- Drop all existing policies to start fresh
DROP POLICY IF EXISTS "Users can manage own rows" ON public.courses;
DROP POLICY IF EXISTS "Allow public read" ON public.courses;
DROP POLICY IF EXISTS "Users can view own courses" ON public.courses;
DROP POLICY IF EXISTS "Users can create courses" ON public.courses;
DROP POLICY IF EXISTS "Public can read verified courses" ON public.courses;
DROP POLICY IF EXISTS "Users can read own courses" ON public.courses;

-- Create comprehensive policies
-- 1. Allow anyone to read verified courses (public courses)
CREATE POLICY "Allow public to read verified courses"
  ON public.courses
  FOR SELECT
  USING (verified = true);

-- 2. Allow authenticated users to read their own courses (verified or not)
CREATE POLICY "Allow users to read own courses"
  ON public.courses
  FOR SELECT
  TO authenticated
  USING (auth.uid() = created_by);

-- 3. Allow authenticated users to create courses
CREATE POLICY "Allow users to create courses"
  ON public.courses
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = created_by);

-- 4. Allow users to update their own courses
CREATE POLICY "Allow users to update own courses"
  ON public.courses
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = created_by)
  WITH CHECK (auth.uid() = created_by);

-- Test the policies
-- You can run these to verify:
-- SELECT * FROM courses WHERE verified = true; -- Should work for anyone
-- SELECT * FROM courses WHERE created_by = auth.uid(); -- Should work for authenticated users