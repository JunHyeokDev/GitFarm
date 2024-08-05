//
//  AppCoordinator.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 7/28/24.
//

//import SwiftUI
//import Combine
//
//class AppCoordinator: ObservableObject {
//    @Published var appState: AppState = .loading
//    @Published var userDataViewModel: UserDataViewModel?
//    @Published var commitHistoryViewModel: CommitHistoryViewModel?
//    
//    let loginManager: LoginManager
//    private var cancellables: Set<AnyCancellable> = []
//    
//    enum AppState {
//        case loading
//        case login
//        case main
//    }
//    
//    init() {
//        self.loginManager = LoginManager.shared
//        setupObservers()
//    }
//    
//    private func setupObservers() {
//        loginManager.$isLoggedIn
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] isLoggedIn in
//                if isLoggedIn {
//                    self?.fetchUserData()
//                } else {
//                    self?.appState = .login
//                    self?.userDataViewModel = nil
//                    self?.commitHistoryViewModel = nil
//                }
//            }
//            .store(in: &cancellables)
//    }
//    
//    func checkLoginStatus() {
//        loginManager.checkLoginStatus()
//    }
//    
//    private func fetchUserData() async {
//         guard let user = loginManager.currentUser else {
//             appState = .login
//             return
//         }
//         
//         appState = .loading
//         
//         let userDataVM = UserDataViewModel()
//         self.userDataViewModel = userDataVM
//         
//         let commitHistoryVM = await CommitHistoryViewModel(with: user)
//         self.commitHistoryViewModel = commitHistoryVM
//         
//         await userDataVM.loadUserData(username: user.login)
//         await commitHistoryVM.fetchCommitHistories(with: user.login)
//         
//         Publishers.CombineLatest4(
//             userDataVM.$isLoading,
//             userDataVM.$error,
//             userDataVM.$commitStats,
//             commitHistoryVM.$commitHistories
//         )
//         .filter { !$0 && $1 == nil && $2 != nil && !$3.isEmpty }
//         .first()  // 조건을 만족하는 첫 번째 이벤트만 처리
//         .receive(on: DispatchQueue.main)
//         .sink { [weak self] _, _, commitStats, _ in
//             if let userDefaults = UserDefaults(suiteName: "group.com.Jun.GitFarm.FarmWidget")  {
//                 let encodedData = try? JSONEncoder().encode(commitStats)
//                 userDefaults.set(encodedData, forKey: "commitTimeline")
//             }
//             self?.appState = .main
//         }
//         .store(in: &cancellables)
//     }
//    
//    func refreshDataInBackground() async {
//        guard let user = loginManager.currentUser else { return }
//        
//        let userDataVM = UserDataViewModel()
//        let commitHistoryVM = await CommitHistoryViewModel(with: user)
//        
//        await withTaskGroup(of: Void.self) { group in
//            group.addTask {
//                await userDataVM.loadUserData(username: user.login)
//            }
//            
//            group.addTask {
//                await commitHistoryVM.fetchCommitHistories(with: user.login)
//            }
//        }
//        
//        DispatchQueue.main.async {
//            self.userDataViewModel = userDataVM
//            self.commitHistoryViewModel = commitHistoryVM
//            
//            if let userDefaults = UserDefaults(suiteName: "group.com.Jun.GitFarm.FarmWidget") {
//                let encodedData = try? JSONEncoder().encode(userDataVM.commitStats)
//                userDefaults.set(encodedData, forKey: "commitTimeline")
//            }
//            if let userDefaults = UserDefaults(suiteName: "group.com.Jun.GitFarm.FarmWidget") {
//                let encodedData = try? JSONEncoder().encode(self.commitHistoryViewModel?.commitHistories)
//                userDefaults.set(encodedData, forKey: "commitHistories")
//            }
//        }
//    }
//}


import SwiftUI
import Combine

class AppCoordinator: ObservableObject {
    @Published var appState: AppState = .loading
    @Published var userDataViewModel: UserDataViewModel?
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
        guard let user = loginManager.currentUser else {
            appState = .login
            return
        }
         
        appState = .loading
         
        let userDataVM = UserDataViewModel()
        self.userDataViewModel = userDataVM
         
        let commitHistoryVM = await CommitHistoryViewModel(with: user)
        self.commitHistoryViewModel = commitHistoryVM
         
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
