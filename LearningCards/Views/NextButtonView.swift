//
//  NextButtonView.swift
//  LearningCards
//
//  Created by Alexander on 14.07.2025.
//

import SwiftUI

struct NextButtonView: View {
    var isValid: Bool
    
    var body: some View {
        Text("Next")
            .frame(maxWidth: .infinity)
            .padding()
            .nunitoBold(size: 18)
            .background(isValid ? .accentColor : Color.gray.opacity(0.2))
            .foregroundColor(isValid ? .white : .gray)
            .cornerRadius(10)
            .padding(.horizontal, 24)
    }
}

#Preview {
    NextButtonView(isValid: true)
}
