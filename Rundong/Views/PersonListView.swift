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
    
    // Basic query for initial loading
    @Query(sort: \DukePerson.DUID) var persons: [DukePerson]
    
    // Control other popups
    @State private var isShowingAddPerson = false
    @State private var isShowingDownloadOptions = false
    @State private var isShowingSortOptions = false
    @State private var selectedPerson: DukePerson? = nil
    
    // Computed properties for filtered and grouped persons
    var filteredPersons: [DukePerson] {
        if vm.searchText.isEmpty {
            return persons
        } else {
            return persons.filter { person in
                person.description.lowercased().contains(vm.searchText.lowercased())
            }
        }
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
                            NavigationLink(destination: PersonView(person: person)) {
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
            .scrollContentBackground(.hidden) // 使列表背景透明
            .background(Color("backgroundColor"))
        }
        .navigationTitle("Persons (\(filteredPersons.count))")
        .toolbar {
            // Exit button
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Exit") {
                    exit(0)
                }
            }
            // Sort button
            ToolbarItem(placement: .navigationBarLeading) {
                Menu {
                    ForEach(PersonListViewModel.SortOption.allCases, id: \.self) { option in
                        Button(option.rawValue) {
                            vm.currentSortOption = option
                        }
                    }
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
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
            // Progress overlay
            if vm.isShowingProgress {
                DownloadOverlayView(progress: $vm.progress, isShowing: $vm.isShowingProgress)
            }
        }
        .sheet(isPresented: $isShowingAddPerson) {
            AddPersonView()
        }
        .navigationDestination(isPresented: Binding<Bool>(
            get: { selectedPerson != nil },
            set: { newValue in if !newValue { selectedPerson = nil } }
        )) {
            if let person = selectedPerson {
                BackPersonView(vm: PersonViewModel(person: person), modelContext: modelContext)
                    .navigationTitle("Edit \(person.fName)")
            }
        }
        .onAppear {
            // Initialize if needed
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
    
    // Animation states
    @State private var blurRadius: CGFloat = 0
    @State private var overlayOpacity: Double = 1.0
    
    var body: some View {
        ZStack {
            // Background: semi-transparent black with blur
            Color.black
                .opacity(0.3)
                .blur(radius: blurRadius)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.5), value: blurRadius)
            
            // Central progress view
            VStack(spacing: 20) {
                Text("Downloading... \(Int(progress * 100))%")
                    .font(.headline)
                    .foregroundColor(.white)
                
                // Custom circular progress
                ZStack {
                    // Track
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 10)
                        .frame(width: 100, height: 100)
                    
                    // Progress indicator
                    Circle()
                        .trim(from: 0, to: CGFloat(progress))
                        .stroke(Color.blue, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90))
                    
                    // Percentage text
                    Text("\(Int(progress * 100))%")
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(30)
            .background(Color.black.opacity(0.7))
            .cornerRadius(20)
            .opacity(overlayOpacity)
            .animation(.easeInOut(duration: 0.3), value: overlayOpacity)
        }
        .onAppear {
            // When shown, increase blur for background
            blurRadius = 5
        }
        .onChange(of: progress) { _, newValue in
            // When progress completes, start fade out
            if newValue >= 1.0 {
                withAnimation(.easeInOut(duration: 0.5).delay(0.5)) {
                    overlayOpacity = 0
                    blurRadius = 0
                }
                
                // After animation, set isShowing to false
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    isShowing = false
                    // Reset states for next use
                    overlayOpacity = 1.0
                    blurRadius = 5
                }
            }
        }
    }
}

struct DownloadOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        DownloadOverlayView(
            progress: .constant(0.65),
            isShowing: .constant(true)
        )
    }
}

#Preview {
    NavigationStack {
        PersonListView()
    }
    .environmentObject(PersonListViewModel())
    .modelContainer(for: DukePerson.self, inMemory: true)
}
