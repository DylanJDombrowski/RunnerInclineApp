// Edge Function: process-gpx
// This processes uploaded GPX files and creates elevation segments
// Save this as: supabase/functions/process-gpx/index.ts

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Get Supabase client with service role (can bypass RLS)
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    
    const supabase = createClient(supabaseUrl, supabaseServiceKey)
    
    // Parse request body
    const { gpx_path, course_id } = await req.json()
    console.log('Processing GPX:', { gpx_path, course_id })
    
    // Download GPX file from storage
    const { data: fileData, error: downloadError } = await supabase.storage
      .from('courses')
      .download(gpx_path)
    
    if (downloadError) {
      throw new Error(`Failed to download GPX: ${downloadError.message}`)
    }
    
    // Convert blob to text
    const gpxContent = await fileData.text()
    console.log('GPX file size:', gpxContent.length, 'characters')
    
    // Parse GPX and extract track points
    const trackPoints = parseGPXTrackPoints(gpxContent)
    console.log('Found', trackPoints.length, 'track points')
    
    if (trackPoints.length === 0) {
      throw new Error('No track points found in GPX file')
    }
    
    // Create segments from track points
    const segments = createSegments(trackPoints, course_id)
    console.log('Created', segments.length, 'segments')
    
    // Insert segments into database
    const { error: insertError } = await supabase
      .from('segments')
      .insert(segments)
    
    if (insertError) {
      throw new Error(`Failed to insert segments: ${insertError.message}`)
    }
    
    console.log('✅ Successfully processed GPX file')
    
    return new Response(
      JSON.stringify({ 
        success: true, 
        segments_created: segments.length 
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200 
      }
    )
    
  } catch (error) {
    console.error('❌ Error processing GPX:', error.message)
    
    return new Response(
      JSON.stringify({ 
        error: error.message 
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400 
      }
    )
  }
})

// Parse GPX content and extract track points
function parseGPXTrackPoints(gpxContent: string) {
  const trackPoints = []
  
  // Simple regex to extract track points (lat, lon, elevation)
  const trkptRegex = /<trkpt\s+lat="([^"]+)"\s+lon="([^"]+)"[^>]*>[\s\S]*?<ele>([^<]+)<\/ele>[\s\S]*?<\/trkpt>/g
  
  let match
  while ((match = trkptRegex.exec(gpxContent)) !== null) {
    const lat = parseFloat(match[1])
    const lon = parseFloat(match[2])
    const ele = parseFloat(match[3])
    
    if (!isNaN(lat) && !isNaN(lon) && !isNaN(ele)) {
      trackPoints.push({ lat, lon, elevation: ele })
    }
  }
  
  return trackPoints
}

// Create segments from track points
function createSegments(trackPoints: any[], courseId: string) {
  const segments = []
  let totalDistance = 0
  
  for (let i = 0; i < trackPoints.length; i++) {
    const point = trackPoints[i]
    
    // Calculate distance from previous point (if not first point)
    if (i > 0) {
      const prevPoint = trackPoints[i - 1]
      const segmentDistance = calculateDistance(prevPoint.lat, prevPoint.lon, point.lat, point.lon)
      totalDistance += segmentDistance
    }
    
    // Calculate grade (if not first point)
    let grade = 0
    if (i > 0) {
      const prevPoint = trackPoints[i - 1]
      const elevationChange = point.elevation - prevPoint.elevation
      const horizontalDistance = calculateDistance(prevPoint.lat, prevPoint.lon, point.lat, point.lon) * 5280 // Convert to feet
      
      if (horizontalDistance > 0) {
        grade = (elevationChange / horizontalDistance) * 100 // Convert to percentage
      }
    }
    
    segments.push({
      course_id: courseId,
      segment_index: i,
      distance_miles: totalDistance,
      elevation_ft: point.elevation,
      grade_percent: Math.round(grade * 100) / 100 // Round to 2 decimal places
    })
  }
  
  return segments
}

// Calculate distance between two lat/lon points in miles
function calculateDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
  const R = 3959 // Earth radius in miles
  const dLat = (lat2 - lat1) * Math.PI / 180
  const dLon = (lon2 - lon1) * Math.PI / 180
  const a = Math.sin(dLat/2) * Math.sin(dLat/2) +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
    Math.sin(dLon/2) * Math.sin(dLon/2)
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
  return R * c
}