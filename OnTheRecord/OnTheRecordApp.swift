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
    let container: ModelContainer

    init() {
        let schema = Schema([Record.self, Track.self])
        let config = ModelConfiguration(
            schema: schema,
            cloudKitDatabase: .private("iCloud.com.adamelaraby.OnTheRecord")
        )
        do {
            container = try ModelContainer(for: schema, configurations: config)
        } catch {
            // Fall back to local-only storage if CloudKit is unavailable
            let localConfig = ModelConfiguration(schema: schema, cloudKitDatabase: .none)
            container = try! ModelContainer(for: schema, configurations: localConfig)
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(container)
    }
}
