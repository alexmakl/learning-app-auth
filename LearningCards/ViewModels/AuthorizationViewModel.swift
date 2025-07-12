//
//  AuthorizationViewModel.swift
//  LearningCards
//
//  Created by Alexander on 04.07.2025.
//

import Foundation
import Combine

final class AuthorizationViewModel: ObservableObject {
    enum ScreenState {
        case phoneInput
        case otpInput
    }
    
    // MARK: - Published Properties
    @Published var phone: String = "" {
        didSet {
            validatePhone()
            phoneMasked = Self.formatPhone(raw: phone)
        }
    }
    @Published var isPhoneValid: Bool = false
    @Published var code: String = "" {
        didSet { validateCode() }
    }
    @Published var isCodeValid: Bool = false
    @Published var screenState: ScreenState = .phoneInput
    @Published var timer: Int = 0
    @Published var error: String? = nil
    @Published var isTimerActive: Bool = false
    @Published var currentFormHeight: CGFloat = 250
    @Published var phoneMasked: String = "+7 "
    
    private var timerCancellable: AnyCancellable?
    private let timerDuration: Int = 30
    
    // MARK: - Validation
    private func validatePhone() {
        // +7 и 10 цифр после
        let pattern = "^\\+7\\d{10}$"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: phone.utf16.count)
        isPhoneValid = regex?.firstMatch(in: phone, options: [], range: range) != nil
    }
    
    private func validateCode() {
        // Только 5 цифр
        let pattern = "^\\d{5}$"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: code.utf16.count)
        isCodeValid = regex?.firstMatch(in: code, options: [], range: range) != nil
    }
    
    func sendCode() {
        guard isPhoneValid else {
            error = String(localized: "Incorrect phone number")
            return
        }
        error = nil
        screenState = .otpInput
        startTimer()
    }
    
    func checkCode() {
        guard isCodeValid else {
            error = String(localized: "Invalid code")
            return
        }
        error = nil
    }
    
    func startTimer() {
        timerCancellable?.cancel()
        timer = timerDuration
        isTimerActive = true
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.timer > 0 {
                    self.timer -= 1
                } else {
                    self.isTimerActive = false
                    self.timerCancellable?.cancel()
                }
            }
    }
    
    func restartTimer() {
        startTimer()
    }
    
    deinit {
        timerCancellable?.cancel()
    }
    
    func setPhoneMasked(_ masked: String) {
        let digits = masked.filter { $0.isNumber }
        var result = "+7"
        let numbers = digits.dropFirst(1)
        for char in numbers.prefix(10) {
            result.append(char)
        }
        phone = result
    }
    
    // MARK: - Маска телефона
    // Отображаемое значение с маской
    // +7 ___ ___-__-__
    // viewModel.phone всегда хранит только цифры с +7
    // Например: +79991234567
    // Форматируем для отображения
    static func formatPhone(raw: String) -> String {
        let digits = raw.filter { $0.isNumber }
        var result = "+7"
        let numbers = digits.dropFirst(1)
        for (i, char) in numbers.prefix(10).enumerated() {
            if i == 0 { result += " " }
            if i == 3 { result += " " }
            if i == 6 { result += "-" }
            if i == 8 { result += "-" }
            result.append(char)
        }
        return result
    }
} 
