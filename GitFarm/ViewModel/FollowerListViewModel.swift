//
//  FollowerListViewModel.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 7/31/24.
//

import Foundation
import Combine

class FollowerListViewModel: ObservableObject {
    @Published var followers: [Follower] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private var cancellables = Set<AnyCancellable>()
    private var currentPage = 1
    private var hasMorePages = true
    private var username: String = ""
    
    func fetchFollowers(for username: String, loadMore: Bool = false) {
        guard !isLoading else { return }
        
        if !loadMore {
            self.username = username
            currentPage = 1
            followers = []
            hasMorePages = true
        }
        
        guard hasMorePages else { return }
        
        isLoading = true
        fetchFromNetwork(for: username)
    }
    
    private func fetchFromNetwork(for username: String) {
        NetworkManager.shared.getFollowers(for: username, page: currentPage)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .finished:
                    print("getFollowers done!")
                case .failure(let error):
                    self?.error = error
                    print("Error fetching followers: \(error)")
                }
            } receiveValue: { [weak self] newFollowers in
                self?.handleReceivedFollowers(newFollowers)
            }
            .store(in: &cancellables)
    }
    
    private func handleReceivedFollowers(_ newFollowers: [Follower]) {
        followers.append(contentsOf: newFollowers)
        hasMorePages = newFollowers.count == 100
        currentPage += 1
    }
    
    func loadMoreIfNeeded(currentItem item: Follower?) {
        guard let item = item else {
            fetchFollowers(for: username, loadMore: true)
            return
        }
        
        let thresholdIndex = followers.index(followers.endIndex, offsetBy: -5)
        if followers.firstIndex(where: { $0.id == item.id }) == thresholdIndex {
            fetchFollowers(for: username, loadMore: true)
        }
    }
}
