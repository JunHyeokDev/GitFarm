//
//  AppCoordinator.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 7/28/24.
//

import SwiftUI
import Combine

class AppCoordinator: ObservableObject {
    @Published var appState: AppState = .loading
    @Published var commitHistoryViewModel: CommitHistoryViewModel?
    
    let loginManager: LoginManager
    private var cancellables: Set<AnyCancellable> = []
    
    enum AppState {
        case loading
        case login
        case main
    }
    
    init() {
        self.loginManager = LoginManager.shared
        setupObservers()
    }
    
    private func setupObservers() {
        loginManager.$isLoggedIn
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoggedIn in
                if isLoggedIn {
                    self?.fetchUserData()
                } else {
                    self?.appState = .login
                    self?.commitHistoryViewModel = nil
                }
            }
            .store(in: &cancellables)
        
        loginManager.$currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                if let user = user {
                    self?.fetchUserData()
                }
            }
            .store(in: &cancellables)
    }
    
    func checkLoginStatus() {
        loginManager.checkLoginStatus()
    }
    
    private func fetchUserData() {
        guard let user = loginManager.currentUser else {
            appState = .login
            return
        }
        
        appState = .loading  // Set state to loading while fetching data
        
        let viewModel = CommitHistoryViewModel(with: user)
        viewModel.fetchCommitHistories(with: user.login)
        
        viewModel.$commitHistories
            .receive(on: DispatchQueue.main)
            .sink { [weak self] histories in
                if !histories.isEmpty {
                    self?.commitHistoryViewModel = viewModel
                    self?.appState = .main
                }
            }
            .store(in: &cancellables)
    }
}
