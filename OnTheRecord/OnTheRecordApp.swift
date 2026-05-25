//
//  OnTheRecordApp.swift
//  OnTheRecord
//
//  Created by Adam on 25/05/2026.
//

import SwiftUI
import SwiftData

@main
struct OnTheRecordApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [Record.self, Track.self])
    }
}
