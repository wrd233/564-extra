//
//  TeamsView.swift
//  Rundong
//
//  Created by MAC on 2025/3/10.
//

import SwiftUI
import SwiftData

struct TeamsView: View {
    @Query var persons: [DukePerson]
    
    var teamsDict: [String: [DukePerson]] {
        let defaultTeam = "Not Applicable"
        
        // Group persons by team
        var dict = [String: [DukePerson]]()
        
        for person in persons {
            let team = person.team.isEmpty ? defaultTeam : person.team
            if dict[team] == nil {
                dict[team] = []
            }
            dict[team]?.append(person)
        }
        
        return dict
    }
    
    var sortedTeams: [(team: String, members: [DukePerson])] {
        teamsDict.map { (team: $0.key, members: $0.value) }
            .sorted { $0.team < $1.team }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ForEach(sortedTeams, id: \.team) { teamGroup in
                    VStack(alignment: .leading, spacing: 12) {
                        // Team name header
                        Text(teamGroup.team)
                            .font(.headline)
                            .padding(.horizontal)
                        
                        // Team members in a horizontal scrollable view
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(teamGroup.members, id: \.DUID) { person in
                                    TeamMemberView(person: person)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Teams")
    }
}

struct TeamMemberView: View {
    let person: DukePerson
    
    var body: some View {
        NavigationLink(destination: PersonView(person: person)) {
            VStack {
                // Profile image
                if !person.picture.isEmpty {
                    ProfileImage(
                        base64String: person.picture,
                        width: 80,
                        height: 80
                    )
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray)
                }
                
                // Name
                Text("\(person.fName) \(person.lName)")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(width: 100)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationStack {
        TeamsView()
    }
    .modelContainer(for: DukePerson.self, inMemory: true)
}
