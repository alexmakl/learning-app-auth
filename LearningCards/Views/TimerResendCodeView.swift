//
//  TimerResendCodeView.swift
//  LearningCards
//
//  Created by Alexander on 14.07.2025.
//

import SwiftUI

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
