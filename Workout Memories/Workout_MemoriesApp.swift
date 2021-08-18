//
//  Workout_MemoriesApp.swift
//  Workout Memories
//
//  Created by Lonnie Gerol on 8/6/21.
//

import SwiftUI
import CoreData

@main
struct Workout_MemoriesApp: App {
    let persistenceController = PersistenceController.shared
    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            MemoriesListView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
