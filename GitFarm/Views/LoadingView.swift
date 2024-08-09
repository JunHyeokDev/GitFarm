//
//  LoadingView.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 7/28/24.
//

import SwiftUI

struct LoadingView: View {
    let message: String
    @State private var leafScale: CGFloat = 0.1
    @State private var leafRotation: Double = -20
    @State private var showLoadingText: Bool = false
    @State private var counter: Int = 0
    
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    init(message: String = "Growing your Farm!🍀 Please wait 🥳") {
        self.message = message
    }
    
    var body: some View {
        VStack {
            ZStack {
                // Leaf
                Image(systemName: "leaf.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.green)
                    .frame(width: 60, height: 60)
                    .scaleEffect(leafScale)
                    .rotationEffect(.degrees(leafRotation))
            }
            .frame(width: 100, height: 120)
            
            ZStack {
                if showLoadingText {
                    HStack(spacing: 0) {
                        ForEach(Array(message.enumerated()), id: \.offset) { index, letter in
                            Text(String(letter))
                                .font(.headline)
                                .foregroundColor(.green)
                                .fontWeight(.heavy)
                                .offset(y: counter == index ? -10 : 0)
                        }
                    }
                    .transition(AnyTransition.scale.animation(.easeIn))
                }
            }
            .frame(height: 40)
        }
        .gradientBackground()
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                leafScale = 1.0
                leafRotation = 10
            }
            showLoadingText = true
        }
        .onReceive(timer) { _ in
            withAnimation(.spring()) {
                let lastIndex = message.count - 1
                if counter == lastIndex {
                    counter = 0
                } else {
                    counter += 1
                }
            }
        }
    }
}
