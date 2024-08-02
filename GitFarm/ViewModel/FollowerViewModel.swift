//
//  FollowerViewModel.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 8/1/24.
//

import Foundation
import Combine

class FollowerViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var commitStats: CommitTimeStatistics?
    @Published var totalCommits: Int = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    func loadUserInfo(username: String) {
        isLoading = true
        NetworkManager.shared.getUserInfo(with: username)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] user in
                print("loadUserInfo done")
                self?.user = user
                self?.loadRepositoriesAndCommits(for: username)  // 여기에 추가
            }
            .store(in: &cancellables)
    }
    
    private func loadRepositoriesAndCommits(for username: String) {
        NetworkManager.shared.getRepositories(for: username)
            .flatMap { repositories -> AnyPublisher<[Commit], Error> in
                let commitPublishers = repositories.map { repo in
                    NetworkManager.shared.getCommits(for: repo.name, owner: username)
                }
                return Publishers.MergeMany(commitPublishers)
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { commits in
                self.analyzeCommits(commits)
            }
            .store(in: &cancellables)
    }
    
    private func analyzeCommits(_ commits: [Commit]) {
        self.totalCommits = commits.count
        
        var stats = CommitTimeStatistics()
        
        let dateFormatter = ISO8601DateFormatter()
        
        for commit in commits {
            if let date = dateFormatter.date(from: commit.commit.author.date) {
                let hour = Calendar.current.component(.hour, from: date)
                switch hour {
                case 6..<12:
                    stats.morning += 1
                case 12..<18:
                    stats.afternoon += 1
                case 18..<24:
                    stats.evening += 1
                default:
                    stats.night += 1
                }
            }
        }
        
        self.commitStats = stats
    }
}
