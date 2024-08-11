//
//  AppCoordinator.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 7/28/24.
//

import SwiftUI
import Combine
import WidgetKit

class AppCoordinator: ObservableObject {
    @Published var appState: AppState = .loading
    @Published var userDataViewModel: UserDataViewModel?
    @Published var commitHistoryViewModel: CommitHistoryViewModel?
    @Published var user : User?
    
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
        setupWidgetRefreshObserver()
    }
    
    private func setupWidgetRefreshObserver() {
        NotificationCenter.default.addObserver(
            forName: Notification.Name("RefreshWidgetDataFromApp"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { [weak self] in
                await self?.refreshWidgetData()
            }
        }
    }
    
    @MainActor
    func refreshWidgetData() async {
        print("refreshWidget here")
        guard let user = loginManager.currentUser else {
            print("No current user found")
            setWidgetLoadingState(false)
            NotificationCenter.default.post(name: Notification.Name("WidgetDataRefreshCompleted"), object: nil)
            return
        }
        
        setWidgetLoadingState(true)
        
        do {
            let userDataVM = UserDataViewModel()
            let commitHistoryVM = await CommitHistoryViewModel(with: user)
            
            await userDataVM.loadUserData(username: user.login)
            await commitHistoryVM.fetchCommitHistories(with: user.login)
            
            guard let userDefaults = UserDefaults(suiteName: "group.com.Jun.GitFarm.FarmWidget") else {
                throw NSError(domain: "AppCoordinator", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to access shared UserDefaults"])
            }
            
            let encoder = JSONEncoder()
            
            do {
                let encodedUser = try encoder.encode(user)
                userDefaults.set(encodedUser, forKey: "userInfoVM")
                
                if let commitStats = userDataVM.commitStats {
                    let encodedStats = try encoder.encode(commitStats)
                    userDefaults.set(encodedStats, forKey: "commitTimeline")
                }
                
                let encodedHistories = try encoder.encode(commitHistoryVM.commitHistories)
                userDefaults.set(encodedHistories, forKey: "commitHistories")
            } catch {
                throw NSError(domain: "AppCoordinator", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to encode data: \(error.localizedDescription)"])
            }
            
            setWidgetLoadingState(false)
            print("Successfully reloaded All Timelines")
        } catch {
            print("Error refreshing widget data: \(error.localizedDescription)")
            setWidgetLoadingState(false)
        }
    }
    
    private func setWidgetLoadingState(_ isLoading: Bool) {
        if let userDefaults = UserDefaults(suiteName: "group.com.Jun.GitFarm.FarmWidget") {
            userDefaults.set(isLoading, forKey: "widgetIsLoading")
        }
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    private func setupObservers() {
        loginManager.$isLoggedIn
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoggedIn in
                if isLoggedIn {
                    Task { [weak self] in
                        guard let self = self else { return }
                        await self.fetchUserData()
                    }
                } else {
                    self?.appState = .login
                    self?.userDataViewModel = nil
                    self?.commitHistoryViewModel = nil
                }
            }
            .store(in: &cancellables)
    }
    
    func checkLoginStatus() {
        loginManager.checkLoginStatus()
    }
    
    @MainActor
    private func fetchUserData() async {
        
        let user = loginManager.currentUser  ?? User.defaultUser
        
        appState = .loading
        
        let userDataVM = UserDataViewModel()
        self.userDataViewModel = userDataVM
        
        let commitHistoryVM = await CommitHistoryViewModel(with: user)
        self.commitHistoryViewModel = commitHistoryVM
        do {
            let newUserinfo = try await NetworkManager.shared.getUserInfo(with: user.login)
            commitHistoryViewModel?.user = newUserinfo
        } catch {
            print("Error refreshing user data: \(error)")
            appState = .login
        }
        
        await userDataVM.loadUserData(username: user.login)
        await commitHistoryVM.fetchCommitHistories(with: user.login)
        
        if !userDataVM.isLoading && userDataVM.error == nil && userDataVM.commitStats != nil && !commitHistoryVM.commitHistories.isEmpty {
            if let userDefaults = UserDefaults(suiteName: "group.com.Jun.GitFarm.FarmWidget") {
                let encodedData = try? JSONEncoder().encode(userDataVM.commitStats)
                userDefaults.set(encodedData, forKey: "commitTimeline")
            }
            appState = .main
        }
    }
    
    func refreshDataInBackground() async {
        guard let user = loginManager.currentUser else { return }
        
        let userDataVM = await UserDataViewModel()
        let commitHistoryVM = await CommitHistoryViewModel(with: user)
        
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await userDataVM.loadUserData(username: user.login)
            }
            
            group.addTask {
                await commitHistoryVM.fetchCommitHistories(with: user.login)
            }
        }
        
        await MainActor.run {
            self.userDataViewModel = userDataVM
            self.commitHistoryViewModel = commitHistoryVM
            
            if let userDefaults = UserDefaults(suiteName: "group.com.Jun.GitFarm.FarmWidget") {
                let encodedData = try? JSONEncoder().encode(userDataVM.commitStats)
                userDefaults.set(encodedData, forKey: "commitTimeline")
            }
            if let userDefaults = UserDefaults(suiteName: "group.com.Jun.GitFarm.FarmWidget") {
                let encodedData = try? JSONEncoder().encode(self.commitHistoryViewModel?.commitHistories)
                userDefaults.set(encodedData, forKey: "commitHistories")
            }
        }
    }
}
