-- ===================================================================
-- Sprint 2 Schema Updates: Course Upload & Authentication
-- Run this manually in Supabase SQL Editor
-- ===================================================================

-- 1. Update RLS policy to allow authenticated users to insert courses
DROP POLICY IF EXISTS "Service role full access" ON "public"."courses";
DROP POLICY IF EXISTS "Authenticated users can create courses" ON "public"."courses";

-- Allow authenticated users to insert new courses (unverified)
CREATE POLICY "Authenticated users can create courses" ON "public"."courses"
    FOR INSERT TO "authenticated" 
    WITH CHECK (verified = false);

-- Keep service role full access for admin operations
CREATE POLICY "Service role full access" ON "public"."courses"
    TO "service_role" 
    USING (true) 
    WITH CHECK (true);

-- 2. Update courses table to include created_by field for tracking
ALTER TABLE "public"."courses" 
ADD COLUMN IF NOT EXISTS "created_by" uuid REFERENCES auth.users(id);

-- 3. Create index for better performance on created_by queries
CREATE INDEX IF NOT EXISTS "idx_courses_created_by" ON "public"."courses" USING btree ("created_by");

-- 4. Allow authenticated users to update their own courses (for GPX URL updates)
CREATE POLICY "Users can update own courses" ON "public"."courses"
    FOR UPDATE TO "authenticated"
    USING (auth.uid() = created_by)
    WITH CHECK (auth.uid() = created_by AND verified = false);

-- 5. Update segments RLS to allow creation for authenticated users' courses
DROP POLICY IF EXISTS "Service role can manage segments" ON "public"."segments";

CREATE POLICY "Service role can manage segments" ON "public"."segments"
    TO "service_role" 
    USING (true) 
    WITH CHECK (true);

-- Allow authenticated users to see segments for their own courses
CREATE POLICY "Users can view segments for own courses" ON "public"."segments"
    FOR SELECT TO "authenticated"
    USING (
        EXISTS (
            SELECT 1 FROM courses 
            WHERE courses.id = segments.course_id 
            AND courses.created_by = auth.uid()
        )
    );

-- 6. Update user_requests to be properly linked to authenticated users
ALTER TABLE "public"."user_requests" 
ALTER COLUMN "user_id" SET NOT NULL;

-- ===================================================================
-- Verification Queries (run these to check your changes)
-- ===================================================================

-- Check RLS policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename IN ('courses', 'segments', 'user_requests');

-- Check table structure
\d courses
\d segments  
\d user_requests

-- ===================================================================
-- Test Data Cleanup (optional - removes test courses)
-- ===================================================================

-- Uncomment to remove test courses created during development
-- DELETE FROM segments WHERE course_id IN (
--     SELECT id FROM courses WHERE name ILIKE '%test%' OR verified = false
-- );
-- DELETE FROM courses WHERE name ILIKE '%test%' OR verified = false;