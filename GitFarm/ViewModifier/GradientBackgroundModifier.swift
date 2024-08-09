//
//  GradientBackgroundModifier.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 8/8/24.
//

import SwiftUI

struct GradientBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.3), Color.blue.opacity(0.3)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            content
        }
    }
}

extension View {
    func gradientBackground() -> some View {
        self.modifier(GradientBackgroundModifier())
    }
}
