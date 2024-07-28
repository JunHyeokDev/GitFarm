//
//  ContentView.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 7/25/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var initViewModel = AppInitViewModel()
    @EnvironmentObject var loginManager: LoginManager
    @StateObject private var commitHistoryViewModel = CommitHistoryViewModel(with: User.defaultUser)
    
    var body: some View {
        Group {
            if loginManager.isLoggedIn {
                if initViewModel.isInitialized {
                    NavSplitView()
                        .environmentObject(commitHistoryViewModel)
                } else {
                    ProgressView("Loading data...")
                }
            } else {
                LoginView()
            }
        }
        .onAppear {
            initViewModel.initialize()
        }
        .onChange(of: loginManager.isLoggedIn) { newValue in
            if newValue, let user = loginManager.currentUser {
                commitHistoryViewModel.updateUser(user)
                commitHistoryViewModel.fetchCommitHistories(with: user.login)
            } else {
                commitHistoryViewModel.reset()
            }
            initViewModel.initialize()
        }
    }
}

