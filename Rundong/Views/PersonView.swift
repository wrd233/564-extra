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
    
    init(person: DukePerson) {
        self.person = person
        _vm = StateObject(wrappedValue: PersonViewModel(person: person))
    }
    
    var body: some View {
        FlipContainer(
            front: FrontPersonView(vm: vm),
            back: BackPersonView(vm: vm, modelContext: modelContext)
        )
        .navigationTitle("\(person.fName) \(person.lName)")
    }
}
