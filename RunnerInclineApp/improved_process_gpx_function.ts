// Improved Edge Function: process-gpx with better error handling
// Replace your current function with this version

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  console.log('🚀 Edge Function started')
  
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    console.log('✅ CORS preflight request')
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    console.log('📥 Processing request...')
    
    // Check environment variables
    const supabaseUrl = Deno.env.get('SUPABASE_URL')
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')
    
    if (!supabaseUrl || !supabaseServiceKey) {
      throw new Error('Missing environment variables: SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY')
    }
    
    console.log('✅ Environment variables found')
    
    // Get Supabase client with service role (can bypass RLS)
    const supabase = createClient(supabaseUrl, supabaseServiceKey)
    console.log('✅ Supabase client created')
    
    // Parse request body
    const body = await req.json()
    const { gpx_path, course_id } = body
    
    console.log('📝 Request data:', { gpx_path, course_id })
    
    if (!gpx_path || !course_id) {
      throw new Error('Missing required parameters: gpx_path or course_id')
    }
    
    console.log('📁 Downloading GPX file from storage...')
    
    // Download GPX file from storage
    const { data: fileData, error: downloadError } = await supabase.storage
      .from('courses')
      .download(gpx_path)
    
    if (downloadError) {
      console.error('❌ Download error:', downloadError)
      throw new Error(`Failed to download GPX: ${downloadError.message}`)
    }
    
    console.log('✅ GPX file downloaded successfully')
    
    // Convert blob to text
    const gpxContent = await fileData.text()
    console.log('📊 GPX file size:', gpxContent.length, 'characters')
    
    if (gpxContent.length === 0) {
      throw new Error('GPX file is empty')
    }
    
    // Parse GPX and extract track points
    const trackPoints = parseGPXTrackPoints(gpxContent)
    console.log('🗺️ Found', trackPoints.length, 'track points')
    
    if (trackPoints.length === 0) {
      console.log('📝 GPX content preview:', gpxContent.substring(0, 500))
      throw new Error('No track points found in GPX file')
    }
    
    // Create segments from track points
    const segments = createSegments(trackPoints, course_id)
    console.log('📈 Created', segments.length, 'segments')
    
    if (segments.length === 0) {
      throw new Error('No segments could be created from track points')
    }
    
    console.log('💾 Inserting segments into database...')
    
    // Insert segments into database
    const { error: insertError } = await supabase
      .from('segments')
      .insert(segments)
    
    if (insertError) {
      console.error('❌ Insert error:', insertError)
      throw new Error(`Failed to insert segments: ${insertError.message}`)
    }
    
    console.log('✅ Successfully processed GPX file')
    
    return new Response(
      JSON.stringify({ 
        success: true, 
        segments_created: segments.length,
        track_points_processed: trackPoints.length,
        course_id: course_id
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200 
      }
    )
    
  } catch (error) {
    console.error('❌ Error processing GPX:', error.message)
    console.error('❌ Error stack:', error.stack)
    
    return new Response(
      JSON.stringify({ 
        error: error.message,
        timestamp: new Date().toISOString()
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
  
  console.log('🔍 Starting GPX parsing...')
  
  // Simple regex to extract track points (lat, lon, elevation)
  const trkptRegex = /<trkpt\s+lat="([^"]+)"\s+lon="([^"]+)"[^>]*>[\s\S]*?<ele>([^<]+)<\/ele>[\s\S]*?<\/trkpt>/g
  
  let match
  let matchCount = 0
  
  while ((match = trkptRegex.exec(gpxContent)) !== null) {
    matchCount++
    const lat = parseFloat(match[1])
    const lon = parseFloat(match[2])
    const ele = parseFloat(match[3])
    
    if (!isNaN(lat) && !isNaN(lon) && !isNaN(ele)) {
      trackPoints.push({ lat, lon, elevation: ele })
    } else {
      console.log('⚠️ Invalid track point data:', { lat: match[1], lon: match[2], ele: match[3] })
    }
  }
  
  console.log('📊 Regex matches found:', matchCount)
  console.log('✅ Valid track points:', trackPoints.length)
  
  return trackPoints
}

// Create segments from track points
function createSegments(trackPoints: any[], courseId: string) {
  console.log('📈 Creating segments from', trackPoints.length, 'points')
  
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
  
  console.log('✅ Segments created:', segments.length)
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