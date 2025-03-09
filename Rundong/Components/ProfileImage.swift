//
//  ProfileImage.swift
//  Rundong
//
//  Created by MAC on 2025/3/10.
//

import SwiftUI

struct ProfileImage: View {
    let base64String: String
    var width: CGFloat = 150
    var height: CGFloat = 150
    
    var body: some View {
        Group {
            if let imageData = Data(base64Encoded: base64String),
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
            }
        }
        .frame(width: width, height: height)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(.white, lineWidth: 4)
                .shadow(color: .black.opacity(0.3), radius: 4)
        )
    }
}

#Preview {
    ProfileImage(base64String: "")
}
