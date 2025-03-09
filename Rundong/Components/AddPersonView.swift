//
//  AddPersonView.swift
//  Rundong
//
//  Created by MAC on 2025/3/10.
//

import SwiftUI
import SwiftData

struct AddPersonView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // New person data
    @State private var duidText: String = ""
    @State private var netID: String = ""
    @State private var fName: String = ""
    @State private var lName: String = ""
    @State private var from: String = ""
    @State private var hobby: String = ""
    @State private var languages: [String] = []
    @State private var moviegenre: String = ""
    @State private var gender: Gender = .Unknown
    @State private var role: Role = .Student
    @State private var program: Program = .NotApplicable
    @State private var plan: Plan = .NotApplicable
    @State private var team: String = ""
    
    // Image related states
    @State private var isShowingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var picture: String = ""
    
    // Validation
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Basic Information")) {
                    TextField("DUID", text: $duidText)
                        .keyboardType(.numberPad)
                    TextField("NetID", text: $netID)
                    TextField("First Name", text: $fName)
                    TextField("Last Name", text: $lName)
                    TextField("From", text: $from)
                    TextField("Hobby", text: $hobby)
                }
                
                Section(header: Text("Additional Info")) {
                    TextField("Favorite Movie Genre", text: $moviegenre)
                    
                    // Languages input (simplified for now)
                    TextField("Languages (comma separated)", text: Binding(
                        get: { languages.joined(separator: ", ") },
                        set: { languages = $0.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) } }
                    ))
                    
                    // Enum selections
                    Picker("Gender", selection: $gender) {
                        ForEach(Gender.allCases, id: \.self) { value in
                            Text(value.rawValue).tag(value)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Picker("Role", selection: $role) {
                        ForEach(Role.allCases, id: \.self) { value in
                            Text(value.rawValue).tag(value)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Picker("Program", selection: $program) {
                        ForEach(Program.allCases, id: \.self) { value in
                            Text(value.rawValue).tag(value)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Picker("Plan", selection: $plan) {
                        ForEach(Plan.allCases, id: \.self) { value in
                            Text(value.rawValue).tag(value)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    TextField("Team", text: $team)
                }
                
                Section(header: Text("Picture")) {
                    Button {
                        isShowingImagePicker = true
                    } label: {
                        HStack {
                            if let image = selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 80)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 80)
                                    .foregroundColor(.gray)
                            }
                            Text("Select Photo")
                        }
                    }
                }
            }
            .navigationTitle("Add New Person")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        savePerson()
                    }
                }
            }
            .sheet(isPresented: $isShowingImagePicker) {
                ImagePicker(image: $selectedImage, isPresented: $isShowingImagePicker, onImagePicked: { image in
                    if let imageData = image.jpegData(compressionQuality: 0.8) {
                        picture = imageData.base64EncodedString()
                    }
                })
            }
            .alert(alertMessage, isPresented: $showingAlert) {
                Button("OK", role: .cancel) {}
            }
        }
    }
    
    func savePerson() {
        // Validate DUID
        guard let newDuid = Int(duidText), newDuid > 0 else {
            alertMessage = "DUID must be a positive number."
            showingAlert = true
            return
        }
        
        // Validate netID
        let netID = self.netID.trimmingCharacters(in: .whitespaces)
        guard !netID.isEmpty else {
            alertMessage = "netID cannot be empty."
            showingAlert = true
            return
        }
        
        // Validate names
        guard !fName.trimmingCharacters(in: .whitespaces).isEmpty else {
            alertMessage = "First Name cannot be empty."
            showingAlert = true
            return
        }
        guard !lName.trimmingCharacters(in: .whitespaces).isEmpty else {
            alertMessage = "Last Name cannot be empty."
            showingAlert = true
            return
        }
        
        // Validate "from" field
        guard !from.trimmingCharacters(in: .whitespaces).isEmpty else {
            alertMessage = "\"From\" cannot be empty."
            showingAlert = true
            return
        }
        
        // Create the new DukePerson
        let newPerson = DukePerson(
            DUID: newDuid,
            netID: netID,
            fName: fName,
            lName: lName,
            from: from,
            hobby: hobby,
            languages: languages,
            moviegenre: moviegenre,
            gender: gender,
            role: role,
            program: program,
            plan: plan,
            team: team,
            picture: picture
        )
        
        // Save to SwiftData
        modelContext.insert(newPerson)
        
        do {
            try modelContext.save()
            print("Successfully added new person")
            dismiss()
        } catch {
            alertMessage = "Error saving person: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

#Preview {
    AddPersonView()
        .modelContainer(for: DukePerson.self, inMemory: true)
}
