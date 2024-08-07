//
//  FollowerView.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 8/1/24.
//

import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct FollowerView: View {
    let username: String
    
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel = UserDataViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isDataReady = false
    
    var body: some View {
        ZStack {
            if viewModel.isLoading || !isDataReady {
                FollowLoadingView()
            } else {
                ScrollView {
                    VStack {
                        if let user = viewModel.user {
                            FollowUserInfoView(user: user)
                            
                            RepositoryStatsView(user: user)
                            
                            if let stats = viewModel.commitStats {
                                CommitStatisticsView(stats: [
                                    ("🐥", "Early Bird", stats.morning, Double(stats.morning) / Double(stats.totalCommits)),
                                    ("🧑‍💻", "Work Hour", stats.afternoon, Double(stats.afternoon) / Double(stats.totalCommits)),
                                    ("🌙", "Over Work", stats.evening, Double(stats.evening) / Double(stats.totalCommits)),
                                    ("🧟", "Coding Zombie", stats.night, Double(stats.night) / Double(stats.totalCommits))
                                ])
                            }
                        } else {
                            Text("No user data available")
                                .foregroundStyle(Color.accent)
                        }
                    }
                    .padding()
                }
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.5), value: isDataReady)
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .task {
            await viewModel.loadUserData(username: username)
            checkDataReadiness()
        }
        .onChange(of: viewModel.user) { _ in
            checkDataReadiness()
        }
        .onChange(of: viewModel.commitStats) { _ in
            checkDataReadiness()
        }
    }
    
    private func checkDataReadiness() {
        if !viewModel.isLoading && viewModel.user != nil && viewModel.commitStats != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    isDataReady = true
                }
            }
        }
    }
}

struct FollowLoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
            Text("Loading data...")
                .foregroundStyle(Color.accent)
                .padding()
        }
    }
}

struct FollowUserInfoView: View {
    let user: User
    
    var body: some View {
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
                        .foregroundStyle(Color.accent)
                        .font(.largeTitle)
                        .font(.system(size: 24, weight: .bold))
                    HStack(spacing: 7) {
                        Image(systemName: "figure.walk")
                            .frame(width: 15, height: 15)
                        Text(user.name ?? String.defaultName())
                            .foregroundStyle(Color.accent)
                            .font(.system(size: 16, weight: .light))
                    }
                    .foregroundStyle(.secondary)
                    HStack(spacing: 7) {
                        Image(systemName: "mappin.and.ellipse")
                            .frame(width: 15, height: 15)
                        Text(user.location ?? String.defaultLocation())
                            .foregroundStyle(Color.accent)
                            .font(.system(size: 16, weight: .light))
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
                    openURL(user.htmlUrl)
                } label: {
                    Text("Check GitHub Profile")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundStyle(Color.accent)
                        .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle()) // 이 줄을 추가합니다
                .padding(.horizontal, -15) // 이 줄을 추가합니다
            }
            .padding()
            .background(Color.accentColor.opacity(0.05))
            .cornerRadius(15)
        }
    }
    
    private func statView(title: String, count: Int) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundStyle(Color.accent)
            Text("\(count)")
                .foregroundStyle(Color.accent)
                .font(.title3)
                .fontWeight(.bold)
        }
    }
}

struct RepositoryStatsView: View {
    let user: User
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            HStack(spacing: 15) {
                statView(title: "Public Repos", count: user.publicRepos)
                Spacer()
                statView(title: "Public Gists", count: user.publicGists)
            }
            
            Button {
                openURL("\(user.htmlUrl)?tab=repositories")
            } label: {
                Text("Check GitHub Repository")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .foregroundStyle(Color.accent)
                    .cornerRadius(10)
            }
            .buttonStyle(PlainButtonStyle()) // 이 줄을 추가합니다
            .padding(.horizontal, -15) // 이 줄을 추가합니다
        }
        .padding()
        .background(colorScheme == .dark ? Color.secondary.opacity(0.2) : Color.secondary.opacity(0.1))
        .cornerRadius(15)
    }
    
    private func statView(title: String, count: Int) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundStyle(Color.accent)
            Text("\(count)")
                .foregroundStyle(Color.accent)
                .font(.title3)
                .fontWeight(.bold)
        }
    }
    

}

struct AlertItem: Identifiable {
    let id = UUID()
    let message: String
}

private func openURL(_ urlString: String) {
    guard let url = URL(string: urlString) else {
        print("Invalid URL")
        return
    }
    
    #if os(iOS)
    if UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url, options: [:])
    } else {
        print("Failed to open the GitHub link")
    }
    #elseif os(macOS)
    NSWorkspace.shared.open(url)
    #endif
}
