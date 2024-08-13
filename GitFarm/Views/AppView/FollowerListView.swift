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
        HStack(alignment: .top) {
            VStack  {
                SearchBar(text: $searchText)
                    .padding(.top)
                
                if !viewModel.isLoading {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 20) {
                            ForEach(filteredFollowers, id: \.id) { follower in
                                NavigationLink(destination: FollowerView(username: follower.login ?? "")) { // NavigationLink 추가
                                    FollowerCell(follower: follower)
                                        .background(Color.clear) // 셀 배경을 투명하게 설정
                                }
                                .buttonStyle(PlainButtonStyle()) // NavigationLink의 기본 스타일 제거
                                .transition(.scale.combined(with: .opacity))
                            }
                            .padding()
                        }
                    }
                }
                
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
            }
            .navigationTitle("Followers")
            .onAppear {
                viewModel.fetchFollowers(for: commitHistoryViewModel.user?.login ?? "")
            }
            .animation(.spring(), value: filteredFollowers)
            //        .sheet(item: $selectedFollower) { follower in
            //            FollowerView(username: follower.login ?? "")
            //                .padding()
            //            #if os(macOS)
            //                .frame(width: 400, height: 650)
            //                            .background(LinearGradient(
            //                                gradient: Gradient(colors: [Color.mint.opacity(0.3), Color.blue.opacity(0.3)]),
            //                                startPoint: .top,
            //                                endPoint: .bottom
            //                            ))
            //                            .presentationDetents([.medium,.large,.fraction(0.75)])
            //            #endif
            //        }
        }
    }
}
