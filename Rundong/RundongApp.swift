//
//  RundongApp.swift
//  Rundong
//
//  Created by MAC on 2025/2/25.
//

import SwiftUI
import SwiftData
import ECE564Login

@main
struct RundongApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            DukePerson.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    @StateObject private var personListVM = PersonListViewModel()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(personListVM)
                .modelContainer(sharedModelContainer)
                .accentColor(Color("AppPrimaryColor"))
                .tint(Color("AppPrimaryColor"))
        }
    }
}
