//
//  extension+View.swift
//  LearningCards
//
//  Created by Alexander on 05.07.2025.
//

import SwiftUI

extension View {
    func nunitoBold(size: CGFloat) -> some View {
        self.font(.custom("Nunito-Bold", size: size))
    }
    func nunitoMedium(size: CGFloat) -> some View {
        self.font(.custom("Nunito-Medium", size: size))
    }
    func nunitoRegular(size: CGFloat) -> some View {
        self.font(.custom("Nunito-Regular", size: size))
    }
}
