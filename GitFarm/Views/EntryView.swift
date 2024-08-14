//
//  EntryView.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 7/26/24.
//

import SwiftUI
import AVFoundation

struct EntryView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @Environment(\.colorScheme) var colorScheme
    
    @State private var isRefreshing = false

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Text("Welcome to GitFarm! 👩🏻‍🌾")
                .foregroundStyle(Color.accent)
                .font(.system(size: 24, weight: .bold))
            
            if let commitHistoryViewModel = appCoordinator.commitHistoryViewModel,
               let userDataViewModel = appCoordinator.userDataViewModel {
                VStack(alignment: .center) {
                    GitCommitHistoryView(commitHistories: commitHistoryViewModel.commitHistories,
                                         user: commitHistoryViewModel.user,
                                         columns: 17,
                                         commitTimeStatistics: userDataViewModel.commitStats ?? CommitTimeStatistics.defaultsInfo())
                        .padding(.all, 10)
                        .background(colorScheme == .dark ? Color.secondary.opacity(0.3) : Color.secondary.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .frame(height: 340)
                .padding(.horizontal, 10)
            } else {
                Text("Loading data...")
            }
        
            Spacer(minLength: 20)
        
            RefreshButton(isRefreshing: $isRefreshing) {
                Task {
                    await appCoordinator.refreshWidgetData()
                    isRefreshing = false
                }
            }
            Spacer()
        }
        .padding(.horizontal, 10)
        .offset(y: 80)
    }
}

struct RefreshButton: View {
    @Binding var isRefreshing: Bool
    let action: () -> Void
    @State private var rotation: Double = 0
    @State private var textOffset: CGFloat = 0
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isAnimating: Bool = false

    var body: some View {
        Button(action: {
            isRefreshing = true
            isAnimating = true
            action()
        }) {
            HStack {
                Image(systemName: "leaf.arrow.circlepath")
                    .font(.system(size: 20))
                    .rotationEffect(.degrees(rotation))
                    .animation(isAnimating ? .linear(duration: 1).repeatForever(autoreverses: false) : .easeInOut(duration: 0.5), value: rotation)

                Text("Refresh Farm")
                    .font(.headline)
                    .offset(y: textOffset)
            }
            .foregroundColor(.white)
            .frame(minWidth: 200, minHeight: 50)
            .background(isRefreshing ? Color.green : Color.green.opacity(0.65))
            .cornerRadius(25)
            .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 3)
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle())
        .disabled(isRefreshing)
        .onChange(of: isRefreshing) { newValue in
            if newValue {
                // Start animations
                withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
                withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                    textOffset = -5
                }
            } else {
                // Stop animations smoothly
                isAnimating = false
                withAnimation(.easeInOut(duration: 0.5)) {
                    rotation = 0
                    textOffset = 0
                }
                // Play completion sound
                playCompletionSound()
            }
        }
        .onAppear(perform: setupAudioPlayer)
    }

    private func setupAudioPlayer() {
        guard let soundURL = Bundle.main.url(forResource: "refresh_sound", withExtension: "mp3") else {
            print("Sound file not found")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.prepareToPlay()
        } catch {
            print("Couldn't initialize AVAudioPlayer: \(error)")
        }
    }

    private func playCompletionSound() {
        audioPlayer?.play()
    }
}

struct PlainButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(Rectangle())
    }
}
