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
    
    // Download manager
    private let downloadService = DownloadManager()
    
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
    
    // Group persons by role
    func groupPersons(_ persons: [DukePerson]) -> [(role: Role, persons: [DukePerson])] {
        let roleOrder: [Role] = [.Professor, .TA, .Student, .Other, .Unknown]
        
        // Create dictionary
        var dict = [Role: [DukePerson]]()
        for role in roleOrder {
            dict[role] = []
        }
        
        // Fill with data
        for person in persons {
            dict[person.role]?.append(person)
        }
        
        // Convert to ordered tuple array
        return roleOrder.compactMap { role in
            guard let persons = dict[role], !persons.isEmpty else { return nil }
            return (role, persons)
        }
    }
}
