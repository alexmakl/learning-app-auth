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

#Preview {
    AuthorizationView()
}
