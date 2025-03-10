//
//  FrontPersonView.swift
//  Rundong
//
//  Created by MAC on 2025/3/10.
//

import SwiftUI

struct FrontPersonView: View {
    @ObservedObject var vm: PersonViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            ProfileImage(base64String: vm.dukePerson.picture)
            
            Text("\(vm.dukePerson.fName) \(vm.dukePerson.lName)")
                .font(.title)
                .fontWeight(.bold)
            
            Text(vm.dukePerson.hobby)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("From: \(vm.dukePerson.from)")
                .font(.caption)
                .foregroundColor(.gray)
            
            TextInfoBlock(content: vm.dukePerson.description)
            
            HStack {
                // Download button
                Button("Download") {
                    Task { await vm.download() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(vm.isLoading)
            }
            .padding()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

// TextInfoBlock component
struct TextInfoBlock: View {
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(content)
                .font(.system(.body, design: .rounded))
                .foregroundStyle(.primary)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.gray.opacity(0.1))
                )
        }
        .padding(.horizontal, 16)
    }
}
