//
//  ErrorView.swift
//  LearningCards
//
//  Created by Alexander on 14.07.2025.
//

import SwiftUI

struct ErrorView: View {
    var error: String
    
    var body: some View {
        Text(error)
            .foregroundStyle(.white)
            .font(.system(size: 16, weight: .bold))
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.red)
    }
}

#Preview {
    ErrorView(error: "Some error")
}
