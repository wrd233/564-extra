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
            // For enum types, use DUID as a stable secondary sort
            return SortDescriptor(\DukePerson.DUID)
        }
    }
    
    // Get FetchDescriptor with predicate for search
    func getFetchDescriptor() -> FetchDescriptor<DukePerson> {
        var descriptor = FetchDescriptor<DukePerson>()
        
        // Add sort descriptor
        descriptor.sortBy = [getSortDescriptor()]
        
        return descriptor
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
                            self?.progress = 1.0
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
                            self?.progress = 1.0
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
    
    // Group persons based on current sort option
    func groupPersons(_ persons: [DukePerson]) -> [(key: String, persons: [DukePerson])] {
        // First, sort persons according to the selected criteria
        let sortedPersons: [DukePerson]
        
        switch currentSortOption {
        case .firstName:
            sortedPersons = persons.sorted { $0.fName < $1.fName }
            return [("All", sortedPersons)]
            
        case .lastName:
            sortedPersons = persons.sorted { $0.lName < $1.lName }
            return [("All", sortedPersons)]
            
        case .role:
            // Define order of role display
            let roleOrder: [Role] = [.Professor, .TA, .Student, .Other, .Unknown]
            var result: [(key: String, persons: [DukePerson])] = []
            
            // Group by role
            for role in roleOrder {
                let filteredPersons = persons.filter { $0.role == role }
                if !filteredPersons.isEmpty {
                    result.append((key: role.rawValue, persons: filteredPersons))
                }
            }
            return result
            
        case .gender:
            // Define order of gender display
            let genderOrder: [Gender] = [.Male, .Female, .Other, .Unknown]
            var result: [(key: String, persons: [DukePerson])] = []
            
            // Group by gender
            for gender in genderOrder {
                let filteredPersons = persons.filter { $0.gender == gender }
                if !filteredPersons.isEmpty {
                    result.append((key: gender.rawValue, persons: filteredPersons))
                }
            }
            return result
            
        case .plan:
            // Define order of plan display
            let planOrder: [Plan] = [.CS, .ECE, .FinTech, .Other, .NotApplicable]
            var result: [(key: String, persons: [DukePerson])] = []
            
            // Group by plan
            for plan in planOrder {
                let filteredPersons = persons.filter { $0.plan == plan }
                if !filteredPersons.isEmpty {
                    result.append((key: plan.rawValue, persons: filteredPersons))
                }
            }
            return result
            
        case .program:
            // Define order of program display
            let programOrder: [Program] = [.MENG, .MS, .PHD, .BA, .BS, .Other, .NotApplicable]
            var result: [(key: String, persons: [DukePerson])] = []
            
            // Group by program
            for program in programOrder {
                let filteredPersons = persons.filter { $0.program == program }
                if !filteredPersons.isEmpty {
                    result.append((key: program.rawValue, persons: filteredPersons))
                }
            }
            return result
        }
    }
}
