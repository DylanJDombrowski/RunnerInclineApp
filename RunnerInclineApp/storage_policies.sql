-- Storage RLS Policies for courses bucket
-- Run this in your Supabase SQL Editor

-- Enable RLS on storage objects
-- (This might already be enabled, but doesn't hurt to run again)

-- Allow authenticated users to upload to courses bucket
CREATE POLICY "Allow authenticated users to upload GPX files"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'courses' 
  AND auth.role() = 'authenticated'
);

-- Allow public read access to courses files (for processing by Edge Functions)
CREATE POLICY "Allow public read access to courses files"
ON storage.objects
FOR SELECT
USING (bucket_id = 'courses');

-- Allow authenticated users to read their own uploaded files
CREATE POLICY "Allow users to read own course files"
ON storage.objects
FOR SELECT
TO authenticated
USING (
  bucket_id = 'courses' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Allow service role (Edge Functions) to read all course files
CREATE POLICY "Allow service role to read course files"
ON storage.objects
FOR SELECT
TO service_role
USING (bucket_id = 'courses');