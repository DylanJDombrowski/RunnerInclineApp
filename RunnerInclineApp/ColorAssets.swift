//
//  ColorAssets.swift
//  RunnerInclineApp
//
//  Created by AI Assistant on 10/28/25.
//
//  This file defines the color assets used in the "Data-Driven Athlete" design system.
//  Add these colors to your Assets.xcassets/Colors folder in Xcode.

/*
 Instructions for adding colors to Xcode:
 
 1. In Xcode, go to your Assets.xcassets folder
 2. Right-click and select "New Color Set"
 3. Name each color set with the exact names below
 4. Set the color values using the hex codes provided
 5. Make sure to set both Light and Dark appearance values if needed
 
 Color Definitions for Assets.xcassets:
 
 ActionGreen: #34C759
 - Primary action color for buttons, active states, and live data
 
 OffBlack: #1C1C1E
 - Primary background color
 
 DarkGray: #2C2C2E
 - Secondary background color for Glassmorphism cards
 
 LightText: #F2F2F7
 - Primary text color for dark backgrounds
 
 MutedText: #98989D
 - Secondary text color and captions
 
 UphillOrange: #FF9500
 - Semantic color for uphill/positive elevation changes
 
 DownhillCyan: #5AC8FA
 - Semantic color for downhill/negative elevation changes
 
*/

import SwiftUI

// Extension to make colors easier to use in code
extension Color {
    static let actionGreen = Color("ActionGreen")
    static let offBlack = Color("OffBlack")
    static let darkGray = Color("DarkGray") 
    static let lightText = Color("LightText")
    static let mutedText = Color("MutedText")
    static let uphillOrange = Color("UphillOrange")
    static let downhillCyan = Color("DownhillCyan")
}