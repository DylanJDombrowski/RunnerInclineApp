


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE OR REPLACE FUNCTION "public"."update_updated_at_column"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
   NEW.updated_at = now();
   RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_updated_at_column"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."courses" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "city" "text",
    "distance_miles" double precision,
    "gpx_url" "text",
    "total_elevation_gain_ft" double precision,
    "source_type" "text",
    "source_link" "text",
    "verified" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "courses_source_type_check" CHECK (("source_type" = ANY (ARRAY['strava'::"text", 'garmin'::"text", 'manual'::"text", 'pdf'::"text"])))
);


ALTER TABLE "public"."courses" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."pace_segments" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "course_id" "uuid" NOT NULL,
    "segment_index" integer NOT NULL,
    "distance_miles" double precision NOT NULL,
    "recommended_pace_seconds_per_mile" integer NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."pace_segments" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."segments" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "course_id" "uuid" NOT NULL,
    "segment_index" integer NOT NULL,
    "distance_miles" double precision NOT NULL,
    "elevation_ft" double precision NOT NULL,
    "grade_percent" double precision,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."segments" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_requests" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "marathon_name" "text" NOT NULL,
    "link" "text",
    "status" "text" DEFAULT 'pending'::"text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "user_requests_status_check" CHECK (("status" = ANY (ARRAY['pending'::"text", 'accepted'::"text", 'rejected'::"text", 'processed'::"text"])))
);


ALTER TABLE "public"."user_requests" OWNER TO "postgres";


ALTER TABLE ONLY "public"."courses"
    ADD CONSTRAINT "courses_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."pace_segments"
    ADD CONSTRAINT "pace_segments_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."segments"
    ADD CONSTRAINT "segments_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_requests"
    ADD CONSTRAINT "user_requests_pkey" PRIMARY KEY ("id");



CREATE INDEX "courses_name_idx" ON "public"."courses" USING "btree" ("name");



CREATE INDEX "idx_courses_created_by" ON "public"."courses" USING "btree" ("created_by");



CREATE INDEX "idx_courses_name" ON "public"."courses" USING "btree" ("name");



CREATE INDEX "idx_pace_segments_course_id" ON "public"."pace_segments" USING "btree" ("course_id");



CREATE INDEX "idx_pace_segments_course_segment" ON "public"."pace_segments" USING "btree" ("course_id", "segment_index");



CREATE INDEX "idx_segments_course_id" ON "public"."segments" USING "btree" ("course_id");



CREATE INDEX "idx_segments_course_segment" ON "public"."segments" USING "btree" ("course_id", "segment_index");



CREATE INDEX "idx_user_requests_status" ON "public"."user_requests" USING "btree" ("status");



CREATE OR REPLACE TRIGGER "set_courses_updated_at" BEFORE UPDATE ON "public"."courses" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



ALTER TABLE ONLY "public"."courses"
    ADD CONSTRAINT "courses_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."pace_segments"
    ADD CONSTRAINT "pace_segments_course_id_fkey" FOREIGN KEY ("course_id") REFERENCES "public"."courses"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."segments"
    ADD CONSTRAINT "segments_course_id_fkey" FOREIGN KEY ("course_id") REFERENCES "public"."courses"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_requests"
    ADD CONSTRAINT "user_requests_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");



CREATE POLICY "Allow public to read pace segments for verified courses" ON "public"."pace_segments" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."courses"
  WHERE (("courses"."id" = "pace_segments"."course_id") AND ("courses"."verified" = true)))));



CREATE POLICY "Allow public to read segments for verified courses" ON "public"."segments" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."courses"
  WHERE (("courses"."id" = "segments"."course_id") AND ("courses"."verified" = true)))));



CREATE POLICY "Allow public to read verified courses" ON "public"."courses" FOR SELECT USING (("verified" = true));



CREATE POLICY "Allow service role to insert pace segments" ON "public"."pace_segments" FOR INSERT TO "service_role" WITH CHECK (true);



CREATE POLICY "Allow service role to insert segments" ON "public"."segments" FOR INSERT TO "service_role" WITH CHECK (true);



CREATE POLICY "Allow users to create courses" ON "public"."courses" FOR INSERT TO "authenticated" WITH CHECK (("auth"."uid"() = "created_by"));



CREATE POLICY "Allow users to read own courses" ON "public"."courses" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "created_by"));



CREATE POLICY "Allow users to read segments for own courses" ON "public"."segments" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."courses"
  WHERE (("courses"."id" = "segments"."course_id") AND ("courses"."created_by" = "auth"."uid"())))));



CREATE POLICY "Allow users to update own courses" ON "public"."courses" FOR UPDATE TO "authenticated" USING (("auth"."uid"() = "created_by")) WITH CHECK (("auth"."uid"() = "created_by"));



CREATE POLICY "Authenticated users can create courses" ON "public"."courses" FOR INSERT TO "authenticated" WITH CHECK (("auth"."uid"() = "created_by"));



CREATE POLICY "Public read access to courses" ON "public"."courses" FOR SELECT USING (true);



CREATE POLICY "Public read verified courses" ON "public"."courses" FOR SELECT USING (("verified" = true));



CREATE POLICY "Service role full access" ON "public"."courses" TO "service_role" USING (true) WITH CHECK (true);



CREATE POLICY "Users can insert requests" ON "public"."user_requests" FOR INSERT TO "authenticated" WITH CHECK (true);



CREATE POLICY "Users can update own courses" ON "public"."courses" FOR UPDATE TO "authenticated" USING (("auth"."uid"() = "created_by")) WITH CHECK (("auth"."uid"() = "created_by"));



ALTER TABLE "public"."courses" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."pace_segments" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."segments" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_requests" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";

























































































































































GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "service_role";


















GRANT ALL ON TABLE "public"."courses" TO "anon";
GRANT ALL ON TABLE "public"."courses" TO "authenticated";
GRANT ALL ON TABLE "public"."courses" TO "service_role";



GRANT ALL ON TABLE "public"."pace_segments" TO "anon";
GRANT ALL ON TABLE "public"."pace_segments" TO "authenticated";
GRANT ALL ON TABLE "public"."pace_segments" TO "service_role";



GRANT ALL ON TABLE "public"."segments" TO "anon";
GRANT ALL ON TABLE "public"."segments" TO "authenticated";
GRANT ALL ON TABLE "public"."segments" TO "service_role";



GRANT ALL ON TABLE "public"."user_requests" TO "anon";
GRANT ALL ON TABLE "public"."user_requests" TO "authenticated";
GRANT ALL ON TABLE "public"."user_requests" TO "service_role";









ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";































RESET ALL;
