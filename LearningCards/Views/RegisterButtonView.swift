//
//  RegisterButtonView.swift
//  LearningCards
//
//  Created by Alexander on 14.07.2025.
//

import SwiftUI

struct RegisterButtonView: View {
    var body: some View {
        Button(action: {
            print("Регистрация")
        }) {
            HStack(alignment: .center, spacing: 8) {
                Text("First time here?")
                    .foregroundColor(.gray)
                Text("Registration")
                    .foregroundColor(.accentColor)
            }
            .nunitoBold(size: 16)
        }
    }
}

#Preview {
    RegisterButtonView()
}
