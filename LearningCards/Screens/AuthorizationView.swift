//
//  AuthorizationView.swift
//  LearningCards
//
//  Created by Alexander on 04.07.2025.
//

import SwiftUI

struct AuthorizationView: View {
    @StateObject private var viewModel = AuthorizationViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                PatternStarView(starSize: geometry.size.height - formHeight(geometry: geometry), animationDuration: 3)
                    .ignoresSafeArea(edges: .top)
                    .frame(height: geometry.size.height - formHeight(geometry: geometry))
                
                VStack(spacing: 14) {
                    switch viewModel.screenState {
                    case .phoneInput:
                        PhoneInputView(viewModel: viewModel)
                    case .otpInput:
                        OTPFormView(viewModel: viewModel)
                    }
                }
                .padding(.vertical, 30)
                .background(
                    Color.white
                        .clipShape(RoundedCorner(radius: 20, corners: [.topLeft, .topRight]))
                        .ignoresSafeArea(edges: .bottom)
                )
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .onAppear {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    viewModel.currentFormHeight = proxy.size.height
                                }
                            }
                            .onChange(of: viewModel.error) { _ in
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    viewModel.currentFormHeight = proxy.size.height
                                }
                            }
                            .preference(key: FormHeightPreferenceKey.self, value: proxy.size.height)
                    }
                )
                .id(viewModel.screenState)
                .onPreferenceChange(FormHeightPreferenceKey.self) { value in
                    if value > 0 {
                        viewModel.currentFormHeight = value
                    }
                }
            }
            .background {
                Color.orange.ignoresSafeArea(edges: .top)
            }
        }
    }
    
    private func formHeight(geometry: GeometryProxy) -> CGFloat {
        return max(viewModel.currentFormHeight, 300)
    }
}

struct FormHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = 20.0
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct OTPFields: View {
    @Binding var code: String
    @FocusState private var focusedIndex: Int?
    @State private var digits: [String] = Array(repeating: "\u{200B}", count: 5)
    @State private var lastDigits: [String] = Array(repeating: "\u{200B}", count: 5)
    
    private let length = 5
    private let zwsp = "\u{200B}"
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<length, id: \.self) { i in
                TextField("", text: $digits[i])
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .nunitoBold(size: 16)
                    .foregroundStyle(.text001)
                    .frame(width: 56, height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .focused($focusedIndex, equals: i)
                    .onChange(of: digits[i]) { newValue in
                        let oldValue = lastDigits[i]
                        defer { lastDigits[i] = digits[i] }
                        
                        var value = newValue
                        if !value.hasPrefix(zwsp) {
                            value = zwsp + value
                            digits[i] = value
                        }
                        
                        let digitsOnly = value.filter(\.isNumber)
                        
                        if (oldValue == zwsp && value == zwsp) || (oldValue == zwsp && value == "")
                        {
                            if i > 0 {
                                digits[i - 1] = zwsp
                                focusedIndex = i - 1
                            }
                            return
                        }
                        else if digitsOnly.count > 1 {
                            for (offset, digit) in digitsOnly.prefix(length - i).enumerated() {
                                digits[i + offset] = zwsp + String(digit)
                            }
                        }
                        else if digitsOnly.count == 1 {
                            if digits[i] != zwsp + String(digitsOnly) {
                                digits[i] = zwsp + String(digitsOnly)
                            }
                            if i < length - 1 {
                                focusedIndex = i + 1
                            }
                        }
                        else {
                            if digits[i] != zwsp {
                                digits[i] = zwsp
                            }
                        }
                        
                        let newCode = digits.map { $0.replacingOccurrences(of: zwsp, with: "") }.joined()
                        if code != newCode {
                            code = newCode
                        }
                    }
            }
        }
        .onAppear {
            let arr = Array(code)
            for i in 0..<length {
                if i < arr.count, arr[i].isNumber {
                    digits[i] = zwsp + String(arr[i])
                } else {
                    digits[i] = zwsp
                }
                lastDigits[i] = digits[i]
            }
            focusedIndex = code.isEmpty ? 0 : min(code.count, length - 1)
        }
    }
}

#Preview {
    AuthorizationView()
}

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

struct EnterTextView: View {
    var body: some View {
        Text("Enter")
            .nunitoBold(size: 28)
            .foregroundColor(.text001)
            .padding(.bottom, 10)
    }
}

struct TimerResendCodeView: View {
    @ObservedObject var viewModel: AuthorizationViewModel
    
    var body: some View {
        HStack(spacing: 8) {
            if viewModel.isTimerActive {
                Text(String(format: "0:%02d", viewModel.timer))
                    .foregroundColor(.text002)
                    .nunitoBold(size: 16)
            }
            Button(action: {
                viewModel.restartTimer()
            }) {
                Text("Send the code again")
                    .foregroundColor(.accentColor)
                    .nunitoBold(size: 16)
            }
            .disabled(viewModel.isTimerActive)
        }
    }
}

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
