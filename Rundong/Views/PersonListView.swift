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
    
    // Use a simpler query with just DUID sorting
    @Query(sort: \DukePerson.DUID) var persons: [DukePerson]
    
    // Control popups
    @State private var isShowingAddPerson = false
    @State private var isShowingDownloadOptions = false
    @State private var isShowingSortOptions = false
    @State private var selectedPerson: DukePerson? = nil
    
    // Computed properties broken down into smaller steps
    var filteredPersons: [DukePerson] {
        vm.filteredPersons(persons)
    }
    
    var groupedPersons: [(key: String, persons: [DukePerson])] {
        vm.groupPersons(filteredPersons)
    }
    
    var body: some View {
        VStack {
            // Search bar
            SearchBar(searchText: $vm.searchText)
                .padding(.top, 8)
            
            // List content
            List {
                ForEach(groupedPersons, id: \.key) { group in
                    Section(header: Text(group.key)) {
                        ForEach(group.persons, id: \.DUID) { person in
                            NavigationLink(destination: Text("Person detail coming soon")) {
                                PersonListItem(person: person)
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
            // Sort button
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    isShowingSortOptions = true
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
        .confirmationDialog("Sort By", isPresented: $isShowingSortOptions) {
            ForEach(PersonListViewModel.SortOption.allCases, id: \.self) { option in
                Button(option.rawValue) {
                    vm.currentSortOption = option
                }
            }
        }
        .confirmationDialog("Please choose a download option", isPresented: $isShowingDownloadOptions, titleVisibility: .visible) {
            Button("Replace") {
                Task {
                    await vm.downloadAll(context: modelContext, persons: Array(persons))
                }
            }
            Button("Update") {
                Task {
                    await vm.downloadAndUpdate(context: modelContext, persons: Array(persons))
                }
            }
            Button("Cancel", role: .cancel) { }
        }
        .overlay {
            if vm.isShowingProgress {
                DownloadOverlayView(progress: $vm.progress, isShowing: $vm.isShowingProgress)
            }
        }
        .sheet(isPresented: $isShowingAddPerson) {
            AddPersonView()
        }
        .onAppear {
            vm.loadInitialData(context: modelContext, persons: Array(persons))
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
