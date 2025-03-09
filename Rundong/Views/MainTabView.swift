//
//  MainTabView.swift
//  Rundong
//
//  Created by MAC on 2025/3/10.
//


import SwiftUI
import ECE564Login

struct MainTabView: View {
    @EnvironmentObject var personListVM: PersonListViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                // First tab - Person List
                NavigationStack {
                    PersonListView()
                }
                .tabItem {
                    Label("List", systemImage: "person.3")
                }
                .tag(0)
                
                // Second tab - Teams View (placeholder for now)
                NavigationStack {
                    Text("Teams View Coming Soon")
                        .navigationTitle("Teams")
                }
                .tabItem {
                    Label("Teams", systemImage: "person.3.sequence")
                }
                .tag(1)
            }
            
            // Add the login component from original code
            ECE564Login()
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(PersonListViewModel())
        .modelContainer(for: DukePerson.self, inMemory: true)
}
