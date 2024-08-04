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
    
    @State private var searchText = ""
    @State private var selectedFollower: Follower?
    
    var filteredFollowers: [Follower] {
        if searchText.isEmpty {
            return viewModel.followers
        } else {
            return viewModel.followers.filter { $0.login?.lowercased().contains(searchText.lowercased()) ?? false }
        }
    }
    
    var body: some View {
        VStack {
            SearchBar(text: $searchText)
                .padding(.top)
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 20) {
                    ForEach(filteredFollowers, id: \.id) { follower in
                        VStack {
                            AsyncImage(url: URL(string: follower.avatarURL ?? "")) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                            } placeholder: {
                                ProgressView()
                            }
                            Text(follower.login ?? "")
                                .foregroundStyle(Color.accent)
                                .font(.caption)
                                .lineLimit(1)
                        }
                        .transition(.scale.combined(with: .opacity))
                        .onTapGesture {
                            selectedFollower = follower
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Followers")
        .onAppear {
            viewModel.fetchFollowers(for: commitHistoryViewModel.user?.login ?? "")
        }
        .animation(.spring(), value: filteredFollowers)
        .sheet(item: $selectedFollower) { follower in
            FollowerView(username: follower.login ?? "")
        }
    }
}
