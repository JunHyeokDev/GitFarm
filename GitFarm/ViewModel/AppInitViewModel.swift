//
//  AppInitViewModel.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 7/27/24.
//

import SwiftUI
import Combine

// MARK: - Refactoring to Async-Await

class AppInitViewModel: ObservableObject {
    @Published var isInitialized: Bool = false
    @Published var error: Error?
    
    private let loginManager: LoginManager
    private let networkManager: NetworkManager
    
    init(loginManager: LoginManager = .shared, networkManager: NetworkManager = .shared) {
        self.loginManager = loginManager
        self.networkManager = networkManager
    }
    
    func initialize() {
        if let user = loginManager.currentUser {
            Task {
                await fetchUserData(for: user.login)
            }
            isInitialized = true
        }
    }
    
    @MainActor
    private func fetchUserData(for username: String) async {
        do {
            async let commitHistories = networkManager.fetchCommitHistories(with: username)
            async let userInfo = networkManager.getUserInfo(with: username)
            
            let (fetchedCommitHistories, fetchedUserInfo) = try await (commitHistories, userInfo)
            
            print("Fetched commit histories: \(fetchedCommitHistories.count)")
            print("Fetched user info: \(fetchedUserInfo)")
            
            // updateCommitHistoryViewModel(with: fetchedCommitHistories, userInfo: fetchedUserInfo)
            
            isInitialized = true
        } catch {
            self.error = error
            isInitialized = true
        }
    }
}
