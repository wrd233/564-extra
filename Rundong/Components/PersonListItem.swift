//
//  PersonListItem.swift
//  Rundong
//
//  Created by MAC on 2025/3/10.
//

import SwiftUI

struct PersonListItem: View {
    let person: DukePerson
    
    var body: some View {
        HStack(spacing: 12) {
            // Render user avatar
            if !person.picture.isEmpty {
                ProfileImage(
                    base64String: person.picture,
                    width: 60,
                    height: 60)
            } else {
                Image(systemName: "person.circle")
                    .resizable()
                    .frame(width: 60, height: 60)
            }
            
            // User primary info
            VStack(alignment: .leading) {
                Text("\(person.fName) \(person.lName)")
                    .font(.headline)
                Text("DUID: \(String(person.DUID))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("NetID: \(String(person.netID))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Email: \(person.email)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Program: \(person.program.rawValue)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Plan: \(person.plan.rawValue)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

#Preview {
    // Create a sample person for the preview
    let person = DukePerson(
        DUID: 123456,
        netID: "test123",
        fName: "John",
        lName: "Doe",
        from: "USA",
        hobby: "Reading",
        languages: ["Swift", "Python"],
        moviegenre: "Sci-Fi",
        gender: .Male,
        role: .Student,
        program: .MENG,
        plan: .CS,
        team: "Team A",
        picture: ""
    )
    
    return PersonListItem(person: person)
        .previewLayout(.sizeThatFits)
        .padding()
}
