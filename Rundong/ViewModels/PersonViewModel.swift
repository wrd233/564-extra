import Foundation
import SwiftData

@MainActor
class PersonViewModel: ObservableObject {
    @Published var dukePerson: DukePerson
    
    // Download-related status
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Edit-related status
    @Published var isEditing = false
    @Published var draftPerson: DukePerson
    
    private let network = NetworkService.shared
    
    // Allow passing data from outside
    init(person: DukePerson) {
        self.dukePerson = person
        self.draftPerson = person
    }
    
    func download() async {
        isLoading = true
        
        do {
            let dto = try await network.downloadPersonDTO()
            
            // Create a new person instance from DTO
            let person = convertDTO2DukePerson(dto: dto)
            
            self.dukePerson = person
            // Save a copy
            self.draftPerson = person
            self.errorMessage = nil
        } catch {
            errorMessage = "Failed: \(error.localizedDescription)"
            print(errorMessage ?? "Unknown error")
        }
        
        isLoading = false
    }
    
    func upload() async {
        do {
            let success = await NetworkService.shared.upload(person: draftPerson)
            print("Upload result: \(success ? "success" : "failure")")
        }
    }
    
    func startEditing() {
        // Create a copy of the current person for editing
        draftPerson = dukePerson
        isEditing = true
    }
    
    func cancelEditing() {
        // Discard changes
        draftPerson = dukePerson
        isEditing = false
    }
    
    func saveChanges(context: ModelContext) {
        // Update the model
        updatePersonProperties(dukePerson, from: draftPerson)
        isEditing = false
        
        // Save changes to SwiftData
        do {
            try context.save()
            print("Successfully saved changes to person")
        } catch {
            print("Failed to save changes: \(error)")
        }
    }
    
    // Helper to update properties without changing the instance
    private func updatePersonProperties(_ target: DukePerson, from source: DukePerson) {
        // We don't update DUID as it's the identifier
        target.netID = source.netID
        target.fName = source.fName
        target.lName = source.lName
        target.from = source.from
        target.hobby = source.hobby
        target.languages = source.languages
        target.moviegenre = source.moviegenre
        target.gender = source.gender
        target.role = source.role
        target.program = source.program
        target.plan = source.plan
        target.team = source.team
        target.picture = source.picture
    }
}
