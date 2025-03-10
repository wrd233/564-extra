//
//  PersonView.swift
//  Rundong
//
//  Created by MAC on 2025/3/10.
//

import SwiftUI
import SwiftData

struct PersonView: View {
    let person: DukePerson
    @StateObject private var vm: PersonViewModel
    @Environment(\.modelContext) private var modelContext
    
    // Track if we're coming from Teams view
    @Environment(\.presentationMode) private var presentationMode
    var fromTeamsView: Bool = false
    
    init(person: DukePerson, fromTeamsView: Bool = false) {
        self.person = person
        self.fromTeamsView = fromTeamsView
        _vm = StateObject(wrappedValue: PersonViewModel(person: person))
    }
    
    var body: some View {
        FlipContainer(
            front: FrontPersonView(vm: vm),
            back: BackPersonView(vm: vm, modelContext: modelContext, fromTeamsView: fromTeamsView)
        )
        .navigationTitle("\(person.fName) \(person.lName)")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}
