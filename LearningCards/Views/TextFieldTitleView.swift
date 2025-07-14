//
//  TextFieldTitleView.swift
//  LearningCards
//
//  Created by Alexander on 14.07.2025.
//

import SwiftUI

struct TextFieldTitleView: View {
    var title: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 4) {
            Text(title)
                .foregroundStyle(.text002)
                .nunitoBold(size: 14)
            Text("*")
                .foregroundStyle(.text003)
                .font(.headline)
            Spacer()
        }
    }
}

#Preview {
    TextFieldTitleView(title: "Title")
}
