//
//  PatternStarView.swift
//  LearningCards
//
//  Created by Alexander on 14.07.2025.
//

import SwiftUI

struct PatternStarView: View {
    @State private var starIndex = 0
    @State private var angle: Double = -10
    @State private var animateForward = true
    let starImages = ["star_happy", "star_sleep", "star_blink"]
    let starSize: CGFloat
    let animationDuration: TimeInterval
    
    var body: some View {
        ZStack {
            Color.orange.ignoresSafeArea()
            Image("background_pattern")
                .resizable()
                .scaledToFill()
            
            Image(starImages[starIndex])
                .resizable()
                .frame(maxWidth: min(236, starSize), maxHeight: min(236, starSize))
                .rotationEffect(.degrees(angle))
                .animation(.easeInOut(duration: animationDuration), value: angle)
                .transition(.scale.combined(with: .opacity))
        }
        .animation(.easeInOut, value: starIndex)
        .onAppear {
            startRotation()
        }
    }
    
    func startRotation() {
        Timer.scheduledTimer(withTimeInterval: animationDuration, repeats: true) { timer in
            withAnimation {
                angle = animateForward ? 10 : -10
            }
            animateForward.toggle()
            if !animateForward {
                DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                    withAnimation {
                        starIndex = (starIndex + 1) % starImages.count
                    }
                }
            }
        }
    }
}

#Preview {
    PatternStarView(starSize: 200, animationDuration: 2)
}
