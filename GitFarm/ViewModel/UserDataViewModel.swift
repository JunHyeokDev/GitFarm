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
    @Published var commitHistories : [CommitHistory]?
    @Published var isLoading = false
    @Published var error: String?
    
    func loadUserData(username: String) async {
        isLoading = true
        error = nil
        
        do {
            async let userInfo = NetworkManager.shared.getUserInfo(with: username)
            async let repositories = NetworkManager.shared.getRepositories(for: username)
            async let commitHistories = NetworkManager.shared.fetchCommitHistories(with: username)
        
            
            let (user, repos, commits) = try await (userInfo, repositories, commitHistories)
            self.user = user
            self.commitHistories = commits
            
            try await loadCommits(for: repos, username: username)
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Parallel Processing
    // each tasks deal different data, So I think It has row possiblity of Race Condition... I guess..?
    private func loadCommits(for repositories: [Repository], username: String) async throws {
        let allCommits = try await withThrowingTaskGroup(of: [Commit].self) { group in
            for repo in repositories {
                group.addTask {
                    let commits = try await NetworkManager.shared.getCommits(for: repo.name, owner: username)
                    return commits
                }
            }
            
            var commits = [Commit]()
            for try await repoCommits in group {
                commits.append(contentsOf: repoCommits)
            }
            return commits
        }
        
        analyzeCommits(allCommits)
    }
    
    
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
    
    
    
    private func loadRepositoriesAndCommits(for username: String) async throws {
        let repositories = try await NetworkManager.shared.getRepositories(for: username)
        var allCommits: [Commit] = []
        
        for repo in repositories {
            let commits = try await NetworkManager.shared.getCommits(for: repo.name, owner: username)
            allCommits.append(contentsOf: commits)
        }
        
        analyzeCommits(allCommits)
    }
}
