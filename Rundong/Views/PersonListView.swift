//
//  PersonListView.swift
//  Rundong
//
//  Created by MAC on 2025/2/25.
//

import SwiftUI
import SwiftData

struct PersonListView: View {
    @EnvironmentObject var vm: PersonListViewModel
    @Environment(\.modelContext) private var modelContext
    @Query var persons: [DukePerson]
    
    // Control other popups
    @State private var isShowingAddPerson = false
    @State private var isShowingDownloadOptions = false
    @State private var selectedPerson: DukePerson? = nil
    
    // Filtered and grouped persons
    var filteredPersons: [DukePerson] {
        vm.filteredPersons(persons)
    }
    
    var groupedPersons: [(role: Role, persons: [DukePerson])] {
        vm.groupPersons(filteredPersons)
    }
    
    var body: some View {
        VStack {
            // Search bar
            SearchBar(searchText: $vm.searchText)
                .padding(.top, 8)
            
            // List view
            List {
                ForEach(groupedPersons, id: \.role) { group in
                    Section(header: Text(group.role.rawValue)) {
                        ForEach(group.persons, id: \.DUID) { person in
                            NavigationLink {
                                Text("Person detail coming soon")
                            } label: {
                                VStack(alignment: .leading) {
                                    Text("\(person.fName) \(person.lName)")
                                        .font(.headline)
                                    Text("DUID: \(person.DUID)")
                                        .font(.subheadline)
                                    Text("NetID: \(person.netID)")
                                        .font(.subheadline)
                                }
                                .padding(.vertical, 4)
                            }
                            .swipeActions(edge: .trailing) {
                                Button("Edit") {
                                    selectedPerson = person
                                }
                                .tint(.blue)
                                
                                Button(role: .destructive) {
                                    removePerson(person)
                                } label: {
                                    Text("Delete")
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Persons")
        .toolbar {
            // Exit button
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Exit") {
                    exit(0)
                }
            }
            // Sort button (placeholder for now)
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    // Sort functionality will be implemented later
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                }
            }
            // Download button
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Download") {
                    isShowingDownloadOptions = true
                }
            }
            // Add button
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isShowingAddPerson = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .confirmationDialog("Please choose a download option", isPresented: $isShowingDownloadOptions, titleVisibility: .visible) {
            Button("Replace") {
                Task {
                    await vm.downloadAll(context: modelContext, persons: persons)
                }
            }
            Button("Update") {
                Task {
                    await vm.downloadAndUpdate(context: modelContext, persons: persons)
                }
            }
            Button("Cancel", role: .cancel) { }
        }
        .overlay {
            // Progress overlay
            if vm.isShowingProgress {
                DownloadOverlayView(progress: $vm.progress, isShowing: $vm.isShowingProgress)
            }
        }
        .onAppear {
            // Initialize if needed
            vm.loadInitialData(context: modelContext, persons: persons)
        }
    }
    
    // Remove a person
    private func removePerson(_ person: DukePerson) {
        modelContext.delete(person)
        do {
            try modelContext.save()
        } catch {
            print("Error deleting person: \(error)")
        }
    }
}

// Search bar component (from original project)
struct SearchBar: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("search", text: $searchText)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.none)
            
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

// Download overlay view (simplified from original project)
struct DownloadOverlayView: View {
    @Binding var progress: Float
    @Binding var isShowing: Bool
    
    var body: some View {
        ZStack {
            Color.black
                .opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Downloading... \(Int(progress * 100))%")
                    .font(.headline)
                    .foregroundColor(.white)
                ProgressView(value: Double(progress))
                    .frame(width: 150)
                    .tint(.blue)
            }
            .padding()
            .background(Color(.systemBackground).opacity(0.8))
            .cornerRadius(10)
        }
    }
}

#Preview {
    NavigationStack {
        PersonListView()
    }
    .environmentObject(PersonListViewModel())
    .modelContainer(for: DukePerson.self, inMemory: true)
}
