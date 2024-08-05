//
//  UserDataViewModel.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 8/3/24.
//

import Combine
import Foundation

@MainActor
class UserDataViewModel: ObservableObject {
    @Published var user: User?
    @Published var commitStats: CommitTimeStatistics?
    @Published var isLoading = false
    @Published var error: String?

//    private var cancellables = Set<AnyCancellable>()
    
//    func loadUserData(username: String) {
//        isLoading = true
//        error = nil
//        
//        NetworkManager.shared.getUserInfo(with: username)
//            .flatMap { [weak self] user -> AnyPublisher<User, Error> in
//                self?.user = user
//                return self?.loadRepositoriesAndCommits(for: username)
//                    .map { _ in user }
//                    .eraseToAnyPublisher() ?? Fail(error: NetworkError.defaultError).eraseToAnyPublisher()
//            }
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] completion in
//                self?.isLoading = false
//                if case .failure(let error) = completion {
//                    self?.error = error.localizedDescription
//                }
//            } receiveValue: { [weak self] user in
//                self?.user = user
//                // 데이터 로딩 완료
//            }
//            .store(in: &cancellables)
//    }
    
    func loadUserData(username: String) async {
        isLoading = true
        error = nil
        
        do {
            let user = try await NetworkManager.shared.getUserInfo(with: username)
            self.user = user
            try await loadRepositoriesAndCommits(for: username)
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
//    private func loadRepositoriesAndCommits(for username: String) -> AnyPublisher<Void, Error> {
//        NetworkManager.shared.getRepositories(for: username)
//            .flatMap { repositories -> AnyPublisher<[Commit], Error> in
//                let commitPublishers = repositories.map { repo in
//                    NetworkManager.shared.getCommits(for: repo.name, owner: username)
//                }
//                return Publishers.MergeMany(commitPublishers)
//                    .collect()
//                    .map { $0.flatMap { $0 } }
//                    .eraseToAnyPublisher()
//            }
//            .map { [weak self] commits in
//                self?.analyzeCommits(commits)
//            }
//            .eraseToAnyPublisher()
//    }
    
    private func loadRepositoriesAndCommits(for username: String) async throws {
        let repositories = try await NetworkManager.shared.getRepositories(for: username)
        var allCommits: [Commit] = []
        
        for repo in repositories {
            let commits = try await NetworkManager.shared.getCommits(for: repo.name, owner: username)
            allCommits.append(contentsOf: commits)
        }
        
        analyzeCommits(allCommits)
    }


//    private func analyzeCommits(_ commits: [Commit]) {
//        var stats = CommitTimeStatistics()
//        let dateFormatter = ISO8601DateFormatter()
//        
//        for commit in commits {
//            if let date = dateFormatter.date(from: commit.commit.author.date) {
//                let hour = Calendar.current.component(.hour, from: date)
//                switch hour {
//                case 6..<12: stats.morning += 1
//                case 12..<18: stats.afternoon += 1
//                case 18..<24: stats.evening += 1
//                default: stats.night += 1
//                }
//            }
//        }
//        
//        stats.totalCommits = commits.count
//        self.commitStats = stats
//    }
    
    private func analyzeCommits(_ commits: [Commit]) {
        var stats = CommitTimeStatistics()
        let dateFormatter = ISO8601DateFormatter()
        
        for commit in commits {
            if let date = dateFormatter.date(from: commit.commit.author.date) {
                let hour = Calendar.current.component(.hour, from: date)
                switch hour {
                case 6..<12: stats.morning += 1
                case 12..<18: stats.afternoon += 1
                case 18..<24: stats.evening += 1
                default: stats.night += 1
                }
            }
        }
        
        stats.totalCommits = commits.count
        self.commitStats = stats
    }
}
