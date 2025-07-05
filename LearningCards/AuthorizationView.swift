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
                PatternStarView()
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
    @State private var digits: [String] = Array(repeating: "", count: 5)
    
    private let length = 5
    
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
                        let filtered = newValue.filter(\.isNumber)
                        if filtered.count > 1 {
                            for (offset, digit) in filtered.prefix(length - i).enumerated() {
                                digits[i + offset] = String(digit)
                            }
                        } else {
                            digits[i] = filtered.isEmpty ? "" : String(filtered.suffix(1))
                        }
                        code = digits.joined()
                        if !digits[i].isEmpty && i < length - 1 {
                            focusedIndex = i + 1
                        }
                    }
            }
        }
        .onAppear {
            focusedIndex = code.isEmpty ? 0 : min(code.count, length - 1)
            let arr = Array(code)
            for i in 0..<length {
                digits[i] = i < arr.count ? String(arr[i]) : ""
            }
        }
    }
}

#Preview {
    AuthorizationView()
}

struct PatternStarView: View {
    @State private var starIndex = 0
    let starImages = ["star_happy", "star_sleep", "star_blink"]
    
    var body: some View {
        ZStack {
            Color.orange.ignoresSafeArea()
            Image("background_pattern")
                .resizable()
                .scaledToFill()
            
            Image(starImages[starIndex])
                .resizable()
                .frame(maxWidth: 236, maxHeight: 236)
                .transition(.scale.combined(with: .opacity))
        }
        .animation(.easeInOut, value: starIndex)
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { _ in
                withAnimation {
                    starIndex = (starIndex + 1) % starImages.count
                }
            }
        }
    }
}

struct PhoneInputView: View {
    @ObservedObject var viewModel: AuthorizationViewModel
    @State private var phoneInput: String = "+7 "
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            EnterTextView()
            
            TextFieldTitleView(title: "Телефон")
            
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
                Text("Впервые тут?")
                    .foregroundColor(.gray)
                Text("Зарегистрироваться")
                    .foregroundColor(.accentColor)
            }
            .nunitoBold(size: 16)
        }
    }
}

struct EnterTextView: View {
    var body: some View {
        Text("Вход")
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
                Text("Отправить код повторно")
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
        Text("Далее")
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
            Text("Введите код")
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
            
            (Text("Мы выслали вам код подтверждения на номер ")
             + Text(viewModel.phoneMasked).bold())
            .nunitoMedium(size: 16)
            .foregroundColor(.text001)
            .fixedSize(horizontal: false, vertical: true)
            
            TextFieldTitleView(title: "Введите код")
            
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
