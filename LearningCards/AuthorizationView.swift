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
                    if viewModel.screenState == .phoneInput {
                        PhoneInputView(viewModel: viewModel)
                        
                        VStack(spacing: 40) {
                            Button(action: {
                                viewModel.sendCode()
                            }) {
                                NextButtonView(isValid: viewModel.isPhoneValid)
                            }
                            .disabled(!viewModel.isPhoneValid)
                            .animation(.easeInOut, value: viewModel.isPhoneValid)
                            
                            if let error = viewModel.error {
                                Text(error)
                                    .foregroundStyle(.white)
                                    .background(.red)
                                    .font(.caption)
                            }
                            
                            RegisterButtonView()
                        }
                        
                    } else if viewModel.screenState == .otpInput {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Вход")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.bottom, 10)

                            (Text("Мы выслали вам код подтверждения на номер ")
                            + Text(viewModel.phoneMasked).bold())
                                .foregroundColor(.text001)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            HStack(alignment: .top, spacing: 4) {
                                Text("Введите код")
                                    .foregroundStyle(.text002)
                                    .font(.headline)
                                Text("*")
                                    .foregroundStyle(.text003)
                                    .font(.headline)
                                Spacer()
                            }
                            
                            OTPFields(code: $viewModel.code)
                                .padding(.vertical, 8)
                        }
                        VStack(spacing: 24) {
                            Button(action: {
                                viewModel.checkCode()
                            }) {
                                NextButtonView(isValid: viewModel.isCodeValid)
                            }
                            .disabled(!viewModel.isCodeValid)
                            .animation(.easeInOut, value: viewModel.isCodeValid)
                            if let error = viewModel.error {
                                Text(error)
                                    .foregroundStyle(.white)
                                    .background(.red)
                                    .font(.caption)
                            }
                            TimerResendCodeView(viewModel: viewModel)
                        }
                    }
                }
                .id(viewModel.screenState)
                .padding(.top, 30)
                .padding([.leading, .trailing], 24)
                .padding(.bottom, 0)
                .background(
                    Color.white
                        .clipShape(RoundedCorner(radius: 20, corners: [.topLeft, .topRight]))
                )
                .background(
                    GeometryReader { formGeometry in
                        Color.clear
                            .preference(key: FormHeightPreferenceKey.self, value: formGeometry.size.height)
                    }
                )
            }
            .onPreferenceChange(FormHeightPreferenceKey.self) { value in
                print("Обновилась высота формы: \(value)")
                viewModel.currentFormHeight = value
            }
            .background {
                Color.orange.ignoresSafeArea(edges: .top)
            }
        }
    }
    
    private func formHeight(geometry: GeometryProxy) -> CGFloat {
        print(viewModel.currentFormHeight)
        return max(viewModel.currentFormHeight, 300)
    }
}

struct FormHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 300
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = 10.0
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
    
    private let length = 5
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<length, id: \ .self) { i in
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        .frame(width: 48, height: 48)
                    TextField("", text: Binding(
                        get: { charAt(i) },
                        set: { setChar($0, at: i) }
                    ))
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .font(.title2)
                    .foregroundStyle(.text001)
                    .focused($focusedIndex, equals: i)
                    .onChange(of: charAt(i)) { _ in
                        if charAt(i).count == 1 && i < length - 1 {
                            focusedIndex = i + 1
                        }
                    }
                }
            }
        }
        .onAppear {
            focusedIndex = code.isEmpty ? 0 : min(code.count, length - 1)
        }
    }
    
    private func charAt(_ i: Int) -> String {
        guard i < code.count else { return "" }
        let idx = code.index(code.startIndex, offsetBy: i)
        return String(code[idx])
    }
    private func setChar(_ new: String, at i: Int) {
        var chars = Array(code)
        if new.isEmpty {
            if i < chars.count {
                chars.remove(at: i)
            }
        } else if let digit = new.last, digit.isNumber {
            if i < chars.count {
                chars[i] = digit
            } else if chars.count < length {
                chars.append(digit)
            }
        }
        code = String(chars.prefix(length))
    }
}

#Preview {
    AuthorizationView()
}

struct PatternStarView: View {
    var body: some View {
        ZStack {
            Color.orange.ignoresSafeArea()
            Image("background_pattern")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Image("star_happy")
                .resizable()
                .frame(width: 236, height: 236)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct PhoneInputView: View {
    @ObservedObject var viewModel: AuthorizationViewModel
    @State private var phoneInput: String = "+7 "
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Вход")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.black)
                .padding(.bottom, 10)
            
            HStack(alignment: .top, spacing: 4) {
                Text("Телефон")
                    .foregroundStyle(.text002)
                    .font(.headline)
                Text("*")
                    .foregroundStyle(.text003)
                    .font(.headline)
                Spacer()
            }
            
            TextField("+7 ___ ___-__-__", text: $phoneInput)
                .onChange(of: phoneInput) { newValue in
                    viewModel.setPhoneMasked(newValue)
                    phoneInput = viewModel.phoneMasked
                }
                .font(Font.title3)
                .foregroundStyle(.text003)
                .keyboardType(.phonePad)
                .padding()
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(viewModel.isPhoneValid ? .accentColor : Color.gray.opacity(0.3), lineWidth: 1)
                )
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
            .font(.headline)
        }
    }
}

struct TimerResendCodeView: View {
    @ObservedObject var viewModel: AuthorizationViewModel
    
    var body: some View {
        HStack(spacing: 8) {
            Text(String(format: "0:%02d", viewModel.timer))
                .foregroundColor(.gray)
            Button(action: {
                viewModel.restartTimer()
            }) {
                Text("Отправить код повторно")
                    .foregroundColor(.accentColor)
                    .bold()
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
            .font(.headline)
            .background(isValid ? .accentColor : Color.gray.opacity(0.2))
            .foregroundColor(isValid ? .white : .gray)
            .cornerRadius(10)
    }
}
