//
//  OTPFields.swift
//  LearningCards
//
//  Created by Alexander on 14.07.2025.
//

import SwiftUI

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
