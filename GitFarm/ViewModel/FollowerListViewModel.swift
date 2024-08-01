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
    private var cancellables = Set<AnyCancellable>()
    
    func fetchFollowers(for username: String) {
        NetworkManager.shared.getFollowers(for: username, page: 1)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Successfully fetched followers")
                case .failure(let error):
                    print("Error fetching followers: \(error)")
                }
            }, receiveValue: { [weak self] followers in
                self?.followers = followers
            })
            .store(in: &cancellables)
    }
}
