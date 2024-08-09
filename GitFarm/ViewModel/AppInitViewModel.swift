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
//        loginManager.checkLoginStatus()
//        
//        if loginManager.isLoggedIn, let user = loginManager.currentUser {
//            Task {
//                await fetchUserData(for: user.login)
//            }
//        } else {
//            isInitialized = true
//        }
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
            
            // Update CommitHistoryViewModel or other relevant parts of your app
            // updateCommitHistoryViewModel(with: fetchedCommitHistories, userInfo: fetchedUserInfo)
            
            isInitialized = true
        } catch {
            self.error = error
            isInitialized = true
        }
    }
}

// MARK: - Before async-await

//class AppInitViewModel: ObservableObject {
//    @Published var isInitialized: Bool = true
//    @Published var error: Error?
//
//    private var cancellables: Set<AnyCancellable> = []
//    private let loginManager: LoginManager
//    private let networkManager: NetworkManager
//
//    init(loginManager: LoginManager = .shared, networkManager: NetworkManager = .shared) {
//        self.loginManager = loginManager
//        self.networkManager = networkManager
//    }
//
//    func initialize() {
//        loginManager.checkLoginStatus()
//
//        if loginManager.isLoggedIn, let user = loginManager.currentUser {
//            fetchUserData(for: user.login)
//        } else {
//            isInitialized = true
//        }
//    }
//
//    private func fetchUserData(for username: String) {
//        networkManager.fetchCommitHistories(with: username)
//            .zip(networkManager.getUserInfo(with: username))
//            .sink(receiveCompletion: { [weak self] completion in
//                switch completion {
//                case .finished:
//                    self?.isInitialized = true
//                case .failure(let error):
//                    self?.error = error
//                }
//            }, receiveValue: { [weak self] (commitHistories, userInfo) in
//                // Here you can store the fetched data or update your app state
//                // For example, you might want to update your CommitHistoryViewModel
//                print("Fetched commit histories: \(commitHistories.count)")
//                print("Fetched user info: \(userInfo)")
//
//                // Update CommitHistoryViewModel or other relevant parts of your app
//                // self?.updateCommitHistoryViewModel(with: commitHistories, userInfo: userInfo)
//            })
//            .store(in: &cancellables)
//    }
//}
