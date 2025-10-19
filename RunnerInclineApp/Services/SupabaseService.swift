//
//  SupabaseService.swift
//  RunnerInclineApp
//
//  Created by Dylan Dombrowski on 10/18/25.
//

import Foundation
import Supabase

final class SupabaseService {
    static let shared = SupabaseService()
    let client: SupabaseClient
    
    private init() {
        guard
            let info = Bundle.main.infoDictionary,
            let url = info["SUPABASE_URL"] as? String,
            let key = info["SUPABASE_ANON_KEY"] as? String
        else {
            fatalError("Missing Supabase configuration in Info.plist")
        }
        client = SupabaseClient(supabaseURL: URL(string: url)!, supabaseKey: key)
    }
}
