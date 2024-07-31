//
//  FollowerListView.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 7/31/24.
//

import SwiftUI
import Combine

struct FollowerListView: View {
    @ObservedObject var commitHistoryViewModel: CommitHistoryViewModel
    @StateObject private var viewModel = FollowerListViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.followers, id: \.id) { follower in
                HStack {
                    AsyncImage(url: URL(string: follower.avatarURL ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    } placeholder: {
                        ProgressView()
                    }
                    Text(follower.login ?? "")
                }
            }
            .navigationTitle("Followers")
            .onAppear {
                viewModel.fetchFollowers(for: commitHistoryViewModel.user?.login ?? "")
            }
        }
    }
}



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
