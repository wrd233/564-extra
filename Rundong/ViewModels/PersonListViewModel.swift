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
    @Published var dummy: String = "" // 保留占位
    
    @Environment(\.modelContext) private var modelContext

    // 传入一个新的 DukePerson 实例
    func insert(person: DukePerson) {
        modelContext.insert(person)
        do {
            try modelContext.save()
            print("Inserted person: \(person.fName) \(person.lName)")
        } catch {
            print("Failed to save after insertion: \(error)")
        }
    }
    
    // 传入要删除的 DukePerson 实例
    func delete(person: DukePerson) {
        modelContext.delete(person)
        do {
            try modelContext.save()
            print("Deleted person: \(person.fName) \(person.lName)")
        } catch {
            print("Failed to save after deletion: \(error)")
        }
    }
}

