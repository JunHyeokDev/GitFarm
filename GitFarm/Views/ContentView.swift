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
            // 그레디언트 컬러 설정.
            LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.3), Color.blue.opacity(0.3)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            Group {
                switch appCoordinator.appState {
                case .loading:
                    LoadingView()

                case .login:
                    LoginView()

                case .main:
                    if let commitHistoryViewModel = appCoordinator.commitHistoryViewModel,
                       let userDataViewModel = appCoordinator.userDataViewModel {
                        NavSplitView()
                            .environmentObject(commitHistoryViewModel)
                            .environmentObject(userDataViewModel)
                            .gradientBackground()
                    } else {
                        LoadingView(message: "Preparing your data...")
                    }
                }
            }
        }
        .onAppear {
            appCoordinator.appState = .loading
            if appCoordinator.appState == .loading {
                appCoordinator.checkLoginStatus()
            }
        }
    }
}
