🏃‍♂️ Sprint 3: The Treadmill Simulation Engine
🎯 Vision: "The Data-Driven Athlete"
This sprint executes the core vision from the new design document. We are building the single most important screen: the Live Treadmill Simulation.

This sprint is not about refactoring old screens. It is about building the "killer feature" that defines the entire product. We will build this new feature to the exact specifications of the new "Glassmorphism" design system.

Strategic Decisions Guiding This Sprint
Curation over Community (v1.0): User uploads are disabled. The GPXUploadView and MyCoursesView will be hidden from the main user flow. This makes the app a premium, curated library, guaranteeing data quality.

New Feature First: We will build the new TreadmillRunView from scratch, using the new design system. Sprint 4 will be dedicated to refactoring the old screens (CourseListView, CourseDetailView) to match.

Pace is Essential: The simulation must include "Recommended Pace" alongside incline.

Watch is Post-v1: All focus is on the iPhone experience.

💡 New Change That Comes to Mind: The "Pace Segment" Model
Your request for "pace" is brilliant and requires a new data model. A GPX file only provides elevation. It has no concept of pace.

To solve this, we will introduce a new table, pace_segments, that perfectly mirrors the existing segments table.

segments: (course_id, segment_index, distance_miles, elevation_ft, grade_percent)

pace_segments (NEW): (course_id, segment_index, distance_miles, recommended_pace_seconds_per_mile)

This allows us to create "Pace Strategies" (e.g., "3:00:00 BQ," "Negative Split") for each course, which an admin (us) will upload. This is a powerful, extensible data model.

The New v1.0 User Flow
MainTabView → CourseListView (Browse "Big 6" Marathons) → CourseDetailView (See full map) → START RUN → TreadmillRunView (The new simulation screen)

🚀 Sprint 3 Core Features: The "Run" Screen
1. New View: TreadmillRunView.swift
This is the new "player" screen, presented modally when a user taps "Start Run" from CourseDetailView. It must be built using the new "Data-Driven Athlete" design system.

Background: Color("OffBlack")

Data: Loads all Segments and PaceSegments for the selected Course.

State: Manages the "run progress" (current distance, current segment_index).

Controls: "Pause," "Resume," and "End Run" buttons.

2. New Component: LiveTreadmillDataView.swift (The "Glassmorphism" Module)
This is the core component from your design doc.

Style: A prominent Glassmorphism card (.ultraThinMaterial, Color("DarkGray") background, white border).

"UP NEXT" Section (Headline):

Text: "Incline to 4.0%"

Text: "Pace to 7:10 /mi"

Caption: "in 0.12 mi"

"CURRENT" Section (Large Display):

DataDisplay Font (Monospaced): "2.5%"

DataDisplay Font (Monospaced): "7:30 /mi"

Animation: All updating numbers must use .contentTransition(.numericText()).

3. New Component: LiveElevationChartView.swift
This component shows the full course chart and the runner's live progress.

Library: import Charts

Base Chart:

AreaMark with LinearGradient from Color("ActionGreen").opacity(0.4) to clear.

LineMark (outline) with Color("ActionGreen") and lineWidth of 2.

Live Progress (The "Scrubber"):

A vertical RuleMark at the viewModel.currentDistance.

A PointMark (circle) following the LineMark to show the runner's exact position.

This will animate as the run progresses.

4. New ViewModel: TreadmillRunViewModel.swift
This is the "engine" that "plays" the run.

Input: Course object.

Data: Fetches and holds [Segment] and [PaceSegment].

Published Properties:

@Published var currentDistance: Double

@Published var currentIncline: Double

@Published var currentPace: Double

@Published var nextIncline: Double

@Published var nextPace: Double

@Published var distanceToNextChange: Double

Logic: Uses a Timer to increment currentDistance. As the distance crosses a new segment_index, it updates all published properties, triggering the UI animations.

🔌 Backend & Data Curation Tasks
This feature is useless without data. This is the other half of the sprint.

1. Admin Task: Seed the "Big 6" Marathon Library
We must acquire and load the "gold standard" courses.

[ ] Acquire GPX: Get high-quality GPX files for Boston, London, Berlin, Chicago, NYC, and Tokyo.

[ ] Admin Upload: Manually upload these GPX files to the courses bucket in Supabase Storage.

[ ] Admin Process: Manually invoke the process-gpx function for each new file to generate the segments.

[ ] Admin Verify: Manually set verified = true in the courses table for these 6 courses.

2. Admin Task: Create Pace Strategies
[ ] Create pace_segments table: (See New Data Models below).

[ ] Define Strategy: For the Boston Marathon, define a "3-hour BQ" pace strategy (a 6:52 min/mile pace).

[ ] Admin Data Entry: Manually INSERT the pace data into the new pace_segments table for the Boston Marathon. (e.g., (course_id_boston, 0, 0.0, 412), (course_id_boston, 1, 0.1, 412), etc.)

3. UI Task: Disable User Uploads
[ ] MainTabView.swift: Remove MyCoursesView from the TabView. The v1.0 tabs will be Home and Profile.

[ ] CourseListView.swift: Remove the + (upload) button from the toolbar.

[ ] ProfileView.swift: (No action needed, auth flow is still required for app use).

🏛️ New Data Models (Schema Changes)
New Table: pace_segments
This SQL must be run in the Supabase SQL Editor.

SQL

-- Create the pace_segments table
CREATE TABLE public.pace_segments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id uuid REFERENCES public.courses(id) ON DELETE CASCADE NOT NULL,
  segment_index integer NOT NULL,
  distance_miles double precision NOT NULL,
  recommended_pace_seconds_per_mile integer NOT NULL, -- e.g., 412
  created_at timestamtz DEFAULT now()
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

CREATE POLICY "Allow service role to insert segments"
  ON public.pace_segments
  FOR INSERT
  TO service_role
  WITH CHECK (true);

-- Create indexes
CREATE INDEX idx_pace_segments_course_id ON public.pace_segments(course_id);
CREATE INDEX idx_pace_segments_course_segment ON public.pace_segments(course_id, segment_index);
New Model: PaceSegment.swift
A new Swift model file to match this table.

Swift

// Models/PaceSegment.swift
import Foundation

struct PaceSegment: Identifiable, Codable {
    let id: UUID
    let course_id: UUID
    let segment_index: Int
    let distance_miles: Double
    let recommended_pace_seconds_per_mile: Int
}
🏁 Sprint 3 Success Criteria
[ ] Feature Complete: A user can select the "Boston Marathon" from the CourseListView, tap "Start Run," and see the new TreadmillRunView.

[ ] Simulation Works: The TreadmillRunView "plays" the run, with the LiveTreadmillDataView and LiveElevationChartView animating in sync.

[ ] Data is Live: The "UP NEXT" module correctly displays incline and pace data fetched from the segments and pace_segments tables.

[ ] Design is Met: The new TreadmillRunView perfectly implements the "Data-Driven Athlete" Glassmorphism design system (monospaced fonts, numeric transitions, etc.).

[ ] Uploads Disabled: The user-facing upload flow is completely hidden from the v1.0 UI.

Sprint 4 Preview
Refactor CourseListView and CourseDetailView to match the new "Data-Driven Athlete" design system.

Implement .matchedGeometryEffect for a seamless transition from CourseListView to CourseDetailView.

Begin planning for the watchOS haptic-feedback app.
