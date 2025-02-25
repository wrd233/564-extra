//
//  PersonListView.swift
//  Rundong
//
//  Created by MAC on 2025/2/25.
//

import SwiftUI
import SwiftData

struct PersonListView: View {
    @Query(sort: \DukePerson.DUID) var persons: [DukePerson]
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationView {
            VStack {
                List(persons, id: \.DUID) { person in
                    VStack(alignment: .leading) {
                        Text("\(person.fName) \(person.lName)")
                            .font(.headline)
                        Text("Role: \(person.role.rawValue)")
                            .font(.subheadline)
                    }
                }
                Button("Download and Refresh") {
                    Task {
                        await refreshDatabase()
                    }
                }
                .padding()
            }
            .navigationTitle("Persons")
        }
        .onAppear {
            // 模拟环境中设置 AuthString
            UserDefaults.standard.set("rw310:rw310", forKey: "AuthString")
            Task {
                await refreshDatabase()
            }
        }
    }
    
    // 清空数据库中所有 DukePerson 记录，然后下载并转换 DTO 数据插入数据库
    private func refreshDatabase() async {
        // 删除所有现有记录
        for person in persons {
            modelContext.delete(person)
        }
        do {
            try modelContext.save()
            print("已清空现有记录")
        } catch {
            print("清空数据库时出错: \(error)")
        }
        
        // 下载 DTO 数组并转换插入数据库
        do {
            let dtoArray = try await NetworkService.shared.fetchAllEntriesDTO()
            convertDTOsToDukePersons(dtoArray: dtoArray, context: modelContext)
        } catch {
            print("下载数据失败: \(error)")
        }
    }
}

struct PersonListView_Previews: PreviewProvider {
    static var previews: some View {
        let container = try! ModelContainer(for: Schema([DukePerson.self]))
        return PersonListView()
            .modelContainer(container)
    }
}
