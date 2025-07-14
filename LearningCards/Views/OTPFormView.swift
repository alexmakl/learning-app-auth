//
//  OTPFormView.swift
//  LearningCards
//
//  Created by Alexander on 14.07.2025.
//

import SwiftUI

struct OTPFormView: View {
    @ObservedObject var viewModel: AuthorizationViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            EnterTextView()
            
            (Text("We've sent you a confirmation code to the number ")
             + Text(viewModel.phoneMasked).bold())
            .nunitoMedium(size: 16)
            .foregroundColor(.text001)
            .fixedSize(horizontal: false, vertical: true)
            
            TextFieldTitleView(title: String(localized: "Enter Code"))
            
            OTPFields(code: $viewModel.code)
                .padding(.vertical, 0)
        }
        .padding(.horizontal, 24)
        
        VStack(spacing: 40) {
            Button(action: {
                viewModel.checkCode()
            }) {
                NextButtonView(isValid: viewModel.isCodeValid)
            }
            .disabled(!viewModel.isCodeValid)
            .animation(.easeInOut, value: viewModel.isCodeValid)
            
            if let error = viewModel.error {
                ErrorView(error: error)
            }
            TimerResendCodeView(viewModel: viewModel)
        }
    }
}
