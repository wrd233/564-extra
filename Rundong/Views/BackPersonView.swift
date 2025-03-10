//
//  BackPersonView.swift
//  Rundong
//
//  Created by MAC on 2025/3/10.
//

import SwiftUI
import SwiftData

struct BackPersonView: View {
    @ObservedObject var vm: PersonViewModel
    let modelContext: ModelContext
    
    @State private var showingAlert = false
    @State private var alertMessage: String = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SectionHeader(title: "Basic Information")
                
                KeyValueRow(key: "DUID", value: .constant("\(vm.draftPerson.DUID)"),
                    isEditable: false
                )
                
                KeyValueRow(
                    key: "NetID",
                    value: .constant("\(vm.draftPerson.netID)"),
                    isEditable: false)
                
                KeyValueRow(
                    key: "From",
                    value: $vm.draftPerson.from,
                    isEditable: vm.isEditing
                )
                
                KeyValueRow(
                    key: "Hobby",
                    value: $vm.draftPerson.hobby,
                    isEditable: vm.isEditing
                )
                
                KeyValueRow(
                    key: "Favorite Movie Genre",
                    value: $vm.draftPerson.moviegenre,
                    isEditable: vm.isEditing
                )
                
                KeyValueEnumRow(
                    key: "Role",
                    selection: $vm.draftPerson.role,
                    isEditable: vm.isEditing
                )
                
                KeyValueEnumRow(
                    key: "Gender",
                    selection: $vm.draftPerson.gender,
                    isEditable: vm.isEditing
                )
                
                SectionHeader(title: "Academic Information")
                
                KeyValueEnumRow(
                    key: "Program",
                    selection: $vm.draftPerson.program,
                    isEditable: vm.isEditing
                )
                
                KeyValueEnumRow(
                    key: "Plan",
                    selection: $vm.draftPerson.plan,
                    isEditable: vm.isEditing
                )
                  
                KeyValueRow(
                    key: "Team",
                    value: $vm.draftPerson.team,
                    isEditable: vm.isEditing
                )
                
                EditableKeyValueListRow(
                    key: "Languages",
                    items: $vm.draftPerson.languages,
                    isEditable: vm.isEditing
                )
                .padding()
                
                HStack {
                    if vm.isEditing {
                        Button("Cancel") {
                            vm.cancelEditing()
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Save") {
                            // Validate inputs
                            if let error = validateInputs() {
                                alertMessage = error
                                showingAlert = true
                            } else {
                                vm.saveChanges(context: modelContext)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        Button("Edit") {
                            vm.startEditing()
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("Upload"){
                            // Check if current logged-in netID matches form
                            let currentNetID = AuthenticationUtils.getCurrentUserNetID() ?? ""
                            if vm.draftPerson.netID != currentNetID {
                                showingAlert = true
                                alertMessage = "This is not your personal information"
                            } else {
                                Task { await vm.upload() }
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
        }
        .alert(alertMessage, isPresented: $showingAlert) {
            Button("OK", role: .cancel) {}
        }
    }
    
    // Validate input fields
    private func validateInputs() -> String? {
        // Validate DUID
        if vm.draftPerson.DUID <= 0 {
            return "DUID must be a positive number."
        }
        // Validate netID
        let netID = vm.draftPerson.netID.trimmingCharacters(in: .whitespaces)
        if netID.isEmpty {
            return "netID cannot be empty."
        }
        // Check if netID contains both letters and numbers
        let letters = CharacterSet.letters
        let digits = CharacterSet.decimalDigits
        let containsLetter = netID.unicodeScalars.contains { letters.contains($0) }
        let containsDigit = netID.unicodeScalars.contains { digits.contains($0) }
        if !containsLetter || !containsDigit {
            return "netID must contain both letters and numbers."
        }
        // Validate From
        if vm.draftPerson.from.trimmingCharacters(in: .whitespaces).isEmpty {
            return "From cannot be empty."
        }
        // All validations passed
        return nil
    }
}

// SectionHeader component
struct SectionHeader: View {
    let title: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Text(title.uppercased())
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundStyle(.secondary)
            }
            
            // Decorative underline
            Rectangle()
                .frame(height: 1.5)
                .foregroundStyle(.gray.opacity(0.3))
                .padding(.trailing, 24)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

// KeyValueRow component
struct KeyValueRow: View {
    let key: String
    @Binding var value: String
    let isEditable: Bool
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(key)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 80, alignment: .leading)
            
            // Display different content based on edit mode
            if isEditable {
                TextField("", text: $value)
                   .textFieldStyle(.roundedBorder)
            } else {
                Text(value)
                .font(.body)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.vertical, 4)
    }
}

// KeyValueEnumRow component
struct KeyValueEnumRow<T: RawRepresentable & CaseIterable & Hashable>: View
where T.RawValue == String {
    let key: String
    @Binding var selection: T
    let isEditable: Bool
    
    var body: some View {
        HStack(alignment: .top) {
            Text(key)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 80, alignment: .leading)
            
            if isEditable {
                Picker("", selection: $selection) {
                    ForEach(Array(T.allCases), id: \.self) { value in
                        Text(value.rawValue).tag(value)
                    }
                }
                .pickerStyle(.menu)
            } else {
                Text(selection.rawValue)
            }
        }
        .padding(.vertical, 4)
    }
}

// EditableKeyValueListRow component
struct EditableKeyValueListRow: View {
    let key: String
    @Binding var items: [String]
    let isEditable: Bool
    var tagColor: Color = .gray.opacity(0.2)
    
    var body: some View {
        HStack(alignment: .top) {
            Text(key)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 80, alignment: .leading)
            
            if isEditable {
                VStack(alignment: .leading) {
                    ForEach(items.indices, id: \.self) { index in
                        HStack {
                            TextField("add here", text: Binding(
                                get: { items[index] },
                                set: { newValue in
                                    if index < items.count {
                                        items[index] = newValue
                                    }
                                }
                            ))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(tagColor)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            
                            Button {
                                if items.count > index {
                                    items.remove(at: index)
                                }
                            } label: {
                                Image(systemName: "trash")
                                   .foregroundStyle(.red)
                            }
                        }
                    }
                    
                    // Add new item button
                    Button {
                        items.append("")
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.blue)
                        }
                    }
                }
            } else {
                // Display mode
                FlowLayout(spacing: 8) {
                    ForEach(items, id: \.self) { value in
                        Text(value)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(tagColor)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// FlowLayout helper for tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let width = proposal.width ?? .infinity
        var height: CGFloat = 0
        var x: CGFloat = 0
        var y: CGFloat = 0
        var maxHeight: CGFloat = 0
        
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > width {
                // Move to next row
                y += maxHeight + spacing
                x = 0
                maxHeight = 0
            }
            
            maxHeight = max(maxHeight, size.height)
            x += size.width + spacing
            
            // Check if this is the widest row
            height = max(height, y + maxHeight)
        }
        
        return CGSize(width: width, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        var x = bounds.minX
        var y = bounds.minY
        var maxHeight: CGFloat = 0
        
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            
            if x + size.width > bounds.maxX {
                // Move to next row
                y += maxHeight + spacing
                x = bounds.minX
                maxHeight = 0
            }
            
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            maxHeight = max(maxHeight, size.height)
            x += size.width + spacing
        }
    }
}
