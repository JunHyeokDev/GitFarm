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
            }
            .store(in: &cancellables)
    }
}
