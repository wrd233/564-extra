//
//  PersonListViewModel.swift
//  Rundong
//
//  Created by MAC on 2025/2/25.
//

import SwiftUI
import SwiftData

@MainActor
class PersonListViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var progress: Float = 0.0
    @Published var isShowingProgress = false
    
    // Add sort option state
    @Published var currentSortOption: SortOption = .role
    
    // Download manager
    private let downloadService = DownloadManager()
    
    // Sort options enum
    enum SortOption: String, CaseIterable {
        case role = "Role"
        case gender = "Gender"
        case plan = "Plan"
        case program = "Program"
        case firstName = "First Name"
        case lastName = "Last Name"
    }
    
    // Called when SwiftData operations are needed
    func loadInitialData(context: ModelContext, persons: [DukePerson]) {
        // Initialize with default data if database is empty
        if persons.isEmpty {
            let defaultPerson = DukePerson(
                DUID: 123456,
                netID: "zz123",
                fName: "Rundong",
                lName: "Wang",
                from: "China",
                hobby: "Sleeping",
                languages: [],
                moviegenre: "Animation",
                gender: .Unknown,
                role: .Student,
                program: .NotApplicable,
                plan: .NotApplicable,
                team: "",
                picture: ""
            )
            
            context.insert(defaultPerson)
            
            do {
                try context.save()
                print("Default person data initialized")
            } catch {
                print("Failed to initialize default data: \(error)")
            }
        }
    }
    
    // Get the appropriate fetch descriptor based on current sort option
    func getSortDescriptor() -> SortDescriptor<DukePerson> {
        switch currentSortOption {
        case .firstName:
            return SortDescriptor(\DukePerson.fName)
        case .lastName:
            return SortDescriptor(\DukePerson.lName)
        case .role, .gender, .plan, .program:
            // For enum types, we'll handle sorting in the grouping function
            // Just return a default sort by DUID
            return SortDescriptor(\DukePerson.DUID)
        }
    }
    
    // Download all entries and replace existing data
    func downloadAll(context: ModelContext, persons: [DukePerson]) async {
        isShowingProgress = true
        progress = 0.0
        
        do {
            let request = try NetworkService.shared.buildFetchAllEntriesRequest()
            downloadService.download(with: request, progress: { [weak self] prog in
                DispatchQueue.main.async {
                    self?.progress = prog
                }
            }, completion: { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        do {
                            let dtoArray = try JSONDecoder().decode([DukePersonDTO].self, from: data)
                            
                            // Clear existing data
                            for person in persons {
                                context.delete(person)
                            }
                            
                            // Insert new data
                            for dto in dtoArray {
                                let person = convertDTO2DukePerson(dto: dto)
                                context.insert(person)
                            }
                            
                            try context.save()
                            print("Downloaded \(dtoArray.count) persons")
                            
                            // Hide progress after completion
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                self?.isShowingProgress = false
                                self?.progress = 0.0
                            }
                            
                        } catch {
                            print("Error processing downloaded data: \(error)")
                            self?.isShowingProgress = false
                        }
                        
                    case .failure(let error):
                        print("Download failed: \(error)")
                        self?.isShowingProgress = false
                    }
                }
            })
        } catch {
            print("Error building request: \(error)")
            isShowingProgress = false
        }
    }
    
    // Download and update existing data
    func downloadAndUpdate(context: ModelContext, persons: [DukePerson]) async {
        isShowingProgress = true
        progress = 0.0
        
        do {
            let request = try NetworkService.shared.buildFetchAllEntriesRequest()
            downloadService.download(with: request, progress: { [weak self] prog in
                DispatchQueue.main.async {
                    self?.progress = prog
                }
            }, completion: { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        do {
                            let dtoArray = try JSONDecoder().decode([DukePersonDTO].self, from: data)
                            
                            // Update existing data or add new records
                            for dto in dtoArray {
                                // Check if person already exists by DUID
                                let existingPerson = persons.first(where: { $0.DUID == dto.DUID })
                                
                                if let existing = existingPerson {
                                    // Update existing record
                                    self?.updatePerson(existing, with: dto)
                                } else {
                                    // Add new record
                                    let newPerson = convertDTO2DukePerson(dto: dto)
                                    context.insert(newPerson)
                                }
                            }
                            
                            try context.save()
                            print("Updated with \(dtoArray.count) persons")
                            
                            // Hide progress after completion
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                self?.isShowingProgress = false
                                self?.progress = 0.0
                            }
                            
                        } catch {
                            print("Error processing downloaded data: \(error)")
                            self?.isShowingProgress = false
                        }
                        
                    case .failure(let error):
                        print("Download failed: \(error)")
                        self?.isShowingProgress = false
                    }
                }
            })
        } catch {
            print("Error building request: \(error)")
            isShowingProgress = false
        }
    }
    
    // Helper method to update existing person with DTO data
    private func updatePerson(_ person: DukePerson, with dto: DukePersonDTO) {
        // Update all fields except DUID (which is the identifier)
        person.netID = dto.netID
        person.fName = dto.fName
        person.lName = dto.lName
        person.from = dto.from
        person.hobby = dto.hobby
        person.languages = dto.languages
        person.moviegenre = dto.moviegenre
        person.gender = Gender(rawValue: dto.gender) ?? .Unknown
        person.role = Role(rawValue: dto.role) ?? .Unknown
        person.program = Program(rawValue: dto.program) ?? .NotApplicable
        person.plan = Plan(rawValue: dto.plan) ?? .NotApplicable
        person.team = dto.team
        person.picture = dto.picture
    }
    
    // Filter persons based on search text
    func filteredPersons(_ persons: [DukePerson]) -> [DukePerson] {
        guard !searchText.isEmpty else {
            return persons
        }
        
        return persons.filter { person in
            person.description.lowercased().contains(searchText.lowercased())
        }
    }
    
    // Group persons based on current sort option
    func groupPersons(_ persons: [DukePerson]) -> [(key: String, persons: [DukePerson])] {
        // If sorting by name, just return a single group with sorted persons
        if currentSortOption == .firstName {
            let sortedPersons = persons.sorted { $0.fName < $1.fName }
            return [("All", sortedPersons)]
        } else if currentSortOption == .lastName {
            let sortedPersons = persons.sorted { $0.lName < $1.lName }
            return [("All", sortedPersons)]
        }
        
        // For other sort options, group by the appropriate property
        var groups: [String: [DukePerson]] = [:]
        
        switch currentSortOption {
        case .role:
            for person in persons {
                let key = person.role.rawValue
                if groups[key] == nil {
                    groups[key] = []
                }
                groups[key]?.append(person)
            }
        case .gender:
            for person in persons {
                let key = person.gender.rawValue
                if groups[key] == nil {
                    groups[key] = []
                }
                groups[key]?.append(person)
            }
        case .plan:
            for person in persons {
                let key = person.plan.rawValue
                if groups[key] == nil {
                    groups[key] = []
                }
                groups[key]?.append(person)
            }
        case .program:
            for person in persons {
                let key = person.program.rawValue
                if groups[key] == nil {
                    groups[key] = []
                }
                groups[key]?.append(person)
            }
        default:
            groups["All"] = persons
        }
        
        // Convert dictionary to array of tuples
        return groups.map { (key: $0.key, persons: $0.value) }
            .sorted { $0.key < $1.key }
    }
}
