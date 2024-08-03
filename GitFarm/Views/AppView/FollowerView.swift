//
//  FollowerView.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 8/1/24.
//

import SwiftUI

struct FollowerView: View {
    let username: String
    
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel = FollowerViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack {
                if viewModel.isLoading {
                    ProgressView()
                } else if let user = viewModel.user {
                    VStack(alignment: .leading, spacing: 30) {
                        HStack(spacing: 10) {
                            AsyncImage(url: URL(string: user.avatarUrl)) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            } placeholder: {
                                ProgressView()
                            }
                            
                            VStack(alignment: .leading, spacing: 10) {
                                Text(user.login)
                                    .font(.largeTitle)
                                    .font(.system(size: 24,weight: .bold))
                                HStack(spacing:7) {
                                    Image(systemName: "figure.walk")
                                        .frame(width: 15,height: 15)
                                    Text(user.name ?? String.defaultName())
                                        .font(.system(size: 16,weight: .light))
                                }
                                .foregroundStyle(.secondary)
                                HStack(spacing:7) {
                                    Image(systemName: "mappin.and.ellipse")
                                        .frame(width: 15,height: 15)
                                    Text(user.location ?? String.defaultLocation())
                                        .font(.system(size: 16,weight: .light))
                                }
                                .foregroundStyle(.secondary)
                            }
                        }
                        VStack {
                            HStack(spacing: 15) {
                                statView(title: "Followers", count: user.followers)
                                Spacer()
                                statView(title: "Following", count: user.following)
                            }
                            Button {

                            } label: {
                                Text("Get Followers")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        .padding()
                        .background(colorScheme == .dark ? Color.accentColor.opacity(0.1) : Color.accentColor.opacity(0.05)) // 배경색 추가
                        .cornerRadius(15)
                    }
                    
                    VStack {
                        HStack(spacing: 15) {
                            statView(title: "Public Repos", count: user.publicRepos)
                            Spacer()
                            statView(title: "Public Gists", count: user.publicGists)
                        }
                        
                        Button {
                            if let url = URL(string: user.htmlUrl), UIApplication.shared.canOpenURL(url) {
                                let options: [UIApplication.OpenExternalURLOptionsKey: Any] = [
                                    .universalLinksOnly: false // 사용자 설정 브라우저를 사용하도록 설정
                                ]
                                UIApplication.shared.open(url, options: options)
                            } else {
                                print("Fail to open the github link..;;")
                            }
                        } label: {
                            Text("Check Github Profile")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.purple)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(colorScheme == .dark ? Color.secondary.opacity(0.2) : Color.secondary.opacity(0.1))
                    .cornerRadius(15)
                    
                    if let stats = viewModel.commitStats {
                        CommitStatisticsView(stats: [
                            ("🐥","Early Bird", stats.morning,Double(stats.morning)/Double(stats.totalCommits)),
                            ("🧑‍💻","Working hours", stats.afternoon,Double(stats.afternoon)/Double(stats.totalCommits)),
                            ("🌙","Over work", stats.evening,Double(stats.evening)/Double(stats.totalCommits)),
                            ("🧟","Coding Zombie", stats.night,Double(stats.night)/Double(stats.totalCommits)),
                        ])
                    }
                    
                } else {
                    Text("No user data available")
                }
            }
            .padding()
        }
        .navigationBarItems(trailing: Button("Done") {
            presentationMode.wrappedValue.dismiss()
        })
        .onAppear {
            print("Appear!")
            viewModel.loadUserInfo(username: username)
        }
    }
    private func statView(title: String, count: Int) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text("\(count)")
                .font(.title3)
                .fontWeight(.bold)
        }
    }
}
