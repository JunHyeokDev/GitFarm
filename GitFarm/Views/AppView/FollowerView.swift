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
    
    let columns = 17
    let rows = 7
    
    @State private var isDataReady = false
    
    // 그라데이션 색상을 상수로 정의
    let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [Color.mint.opacity(0.3), Color.blue.opacity(0.3)]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundGradient
                    .edgesIgnoringSafeArea(.all)
                
                if viewModel.isLoading || !isDataReady {
                    FollowLoadingView()
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            if let user = viewModel.user,
                               let stats = viewModel.commitStats,
                               let commitHistories = viewModel.commitHistories {
                                FollowUserInfoView(user: user)
                                    .frame(width: geometry.size.width * 0.9)
                                
                                RepositoryStatsView(user: user)
                                    .frame(width: geometry.size.width * 0.9)
                                
                                VStack(spacing: 15) {
                                    SkyView()
                                        .frame(height: 30)
                                    
                                    GitCommitView(columns: columns, rows: rows, size: CGSize(width: geometry.size.width * 0.9, height: 450)) { column, row in
                                        Group {
                                            if let commitHistory = CommitHistoryViewModel.commitHistorySet(with: commitHistories, columnsCount: columns).element(at: row)?.element(at: column) {
                                                GitCommitCellView(commitHistory: commitHistory)
                                            } else {
                                                Color.clear
                                                    .frame(height: 17)
                                            }
                                        }
                                    }
                                    .padding(.vertical, 10)
                                    
                                    CommitStatisticsView(stats: [
                                        ("🐥","Early Bird", stats.morning,Double(stats.morning)/Double(stats.totalCommits)),
                                        ("🧑‍💻","Working hours", stats.afternoon,Double(stats.afternoon)/Double(stats.totalCommits)),
                                        ("🌙","Over work", stats.evening,Double(stats.evening)/Double(stats.totalCommits)),
                                        ("🧟","Coding Zombie", stats.night,Double(stats.night)/Double(stats.totalCommits)),
                                    ])
                                    .padding(.vertical, 10)
                                }
                                .frame(width: geometry.size.width * 0.9)
                                .background(colorScheme == .dark ? Color.secondary.opacity(0.3) : Color.secondary.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                            } else {
                                Text("No user data available")
                                    .foregroundStyle(Color.accent)
                            }
                        }
                        .frame(width: geometry.size.width)
                    }
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.5), value: isDataReady)
                }
            }
        }
        .padding(.vertical,10)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.blue) // 색상 변경
            }
        }
//        #if os(iOS)
//                .toolbar {
//                    ToolbarItem(placement: .confirmationAction) {
//                        Button("Done") {
//                            presentationMode.wrappedValue.dismiss()
//                        }
//                        .buttonStyle(.borderedProminent)
//                        .tint(Color.blue)
//                    }
//                }
//                .toolbarBackground(backgroundGradient, for: .navigationBar) // iOS/iPad에서 툴바 배경에 그라데이션 적용
//        #elseif os(macOS)
//                .toolbar {
//                    ToolbarItem(placement: .confirmationAction) {
//                        Button("Done") {
//                            presentationMode.wrappedValue.dismiss()
//                        }
//                        .buttonStyle(.borderedProminent)
//                        .tint(Color.blue)
//                    }
//                }
//                .toolbarBackground(backgroundGradient, for: .windowToolbar) // macOS에서 툴바 배경에 그라데이션 적용
//        #endif
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
            HStack(spacing: 20) {
                //Image
                AsyncImage(url: URL(string: user.avatarUrl)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                        .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 2)
                } placeholder: {
                    ProgressView()
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text(user.login)
                        .foregroundColor(.primary)
                        .font(.system(size: 24, weight: .bold))
                    HStack(spacing: 7) {
                        Image(systemName: "figure.walk")
                            .frame(width: 15, height: 15)
                        Text(user.name ?? String.defaultName())
                            .foregroundColor(.primary)
                            .font(.system(size: 16, weight: .medium))
                    }
                    HStack(spacing: 7) {
                        Image(systemName: "mappin.and.ellipse")
                            .frame(width: 15, height: 15)
                        Text(user.location ?? String.defaultLocation())
                            .foregroundColor(.primary)
                            .font(.system(size: 16, weight: .medium))
                    }
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
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
            .background(Color.accentColor.opacity(0.05))
            //.background(Color.white.opacity(0.8))
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        }
    }
    
    private func statView(title: String, count: Int) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text("\(count)")
                .foregroundColor(.primary)
                .font(.title3)
                .fontWeight(.bold)
        }
    }
}

struct RepositoryStatsView: View {
    let user: User
    
    var body: some View {
        VStack(spacing: 15) {
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
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .background(Color.accentColor.opacity(0.05))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    private func statView(title: String, count: Int) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text("\(count)")
                .foregroundColor(.primary)
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
