//
//  ContentView.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 7/25/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appCoordinator: AppCoordinator
    
    var body: some View {
        ZStack {
            Group {
                switch appCoordinator.appState {
                case .loading:
                    LoadingView(message: "Setting up your Git farm...")
                case .login:
                    LoginView()
                        .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity),
                                                removal: .move(edge: .top).combined(with: .opacity)))
                case .main:
                    if let commitHistoryViewModel = appCoordinator.commitHistoryViewModel,
                       let userDataViewModel = appCoordinator.userDataViewModel {
                        NavSplitView()
                            .environmentObject(commitHistoryViewModel)
                            .environmentObject(userDataViewModel)
                            .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                                    removal: .move(edge: .leading).combined(with: .opacity)))
                    } else {
                        LoadingView(message: "Preparing your data...")
                    }
                }
            }
            .animation(.easeIn(duration: 0.2), value: appCoordinator.appState)
        }
        .onAppear {
            if appCoordinator.appState == .loading {
                appCoordinator.checkLoginStatus()
            }
        }
    }
}
