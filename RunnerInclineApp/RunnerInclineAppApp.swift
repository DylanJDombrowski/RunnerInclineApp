//
//  RunnerInclineAppApp.swift
//  RunnerInclineApp
//
//  Created by Dylan Dombrowski on 10/18/25.
//

import SwiftUI

@main
struct RunnerInclineAppApp: App {
    init() {
        print("🚀 App launched successfully")
    }

    var body: some Scene {
        WindowGroup {
            CourseListView()
        }
    }
}
