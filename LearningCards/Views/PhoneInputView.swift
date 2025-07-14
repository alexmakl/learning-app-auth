//
//  PhoneInputView.swift
//  LearningCards
//
//  Created by Alexander on 14.07.2025.
//

import SwiftUI

struct PhoneInputView: View {
    @ObservedObject var viewModel: AuthorizationViewModel
    @State private var phoneInput: String = "+7 "
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            EnterTextView()
            
            TextFieldTitleView(title: String(localized: "Phone"))
            
            TextField("+7 ___ ___-__-__", text: $phoneInput)
                .onChange(of: phoneInput) { newValue in
                    viewModel.setPhoneMasked(newValue)
                    phoneInput = viewModel.phoneMasked
                }
                .nunitoBold(size: 16)
                .foregroundStyle(isTextFieldFocused ? .text001 : .text003)
                .keyboardType(.phonePad)
                .padding()
                .cornerRadius(8)
                .focused($isTextFieldFocused)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(viewModel.isPhoneValid ? .accentColor : Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
        .padding(.horizontal, 24)
        
        VStack(spacing: 40) {
            Button(action: {
                viewModel.sendCode()
            }) {
                NextButtonView(isValid: viewModel.isPhoneValid)
            }
            .disabled(!viewModel.isPhoneValid)
            .animation(.easeInOut, value: viewModel.isPhoneValid)
            
            if let error = viewModel.error {
                ErrorView(error: error)
            }
            
            RegisterButtonView()
        }
    }
}
