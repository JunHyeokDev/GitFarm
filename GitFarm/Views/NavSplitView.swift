//
//  NavSplitView.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 7/25/24.
//

import SwiftUI

struct NavSplitView: View {
    @EnvironmentObject var commitHistoryViewModel: CommitHistoryViewModel
    @EnvironmentObject var userDataViewModel: UserDataViewModel
    @State private var selection: Panel? = Panel.myFarm
    @State private var path = NavigationPath()
    @State private var showingLogoutAlert = false
    @State private var previousSelection: Panel? = nil


    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                // Top Image
                UserInfoView(user: commitHistoryViewModel.user ?? User.defaultUser)
                    .frame(height: 300)
                    .padding()
                
                // Sidebar content
                Sidebar(selection: $selection)

                // Logout button
                Button(action: {
                    showingLogoutAlert = true
                }) {
                    Text("Logout")
                        .foregroundColor(.red)
                        .padding()
                }
                .alert(isPresented: $showingLogoutAlert) {
                    Alert(
                        title: Text("Logout"),
                        message: Text("Are you sure you want to logout?"),
                        primaryButton: .destructive(Text("Logout")) {
                            logout()
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
            .gradientBackground()
        } detail: {
            NavigationStack(path: $path) {
                DetailView(selection: $selection, commitHistoryViewModel: commitHistoryViewModel, userDataViewModel: userDataViewModel)
                    .id(selection) // 뷰를 식별하기 위한 고유 ID
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            }
            .animation(.easeInOut(duration: 0.3), value: selection)
        }
        .navigationSplitViewStyle(.balanced)
        .onChange(of: selection) { newValue in
            withAnimation {
                previousSelection = selection
            }
        }
    }
        
    private func logout() {
        LoginManager.shared.logout()
        print("User logged out")
    }
}

enum Category: String, CaseIterable, Identifiable {
    case status, myFarm, logout
    var id: Self { self }
    
    var title: String {
        switch self {
        case .myFarm:
            return "My Farm"
        case .logout:
            return "Logout"
        default:
            return rawValue.split(separator: " ").map { $0.capitalized }.joined(separator: " ")
        }
    }
    
    var items: [MyItem] {
        switch self {
        case .status:
            return [MyItem(name: "MyFarm", description: "A sweet, edible fruit produced by an apple tree.")]
        case .myFarm:
            return [MyItem(name: "Carrot", description: "A tapering orange-colored root eaten as a vegetable.")]
        case .logout:
            return []
        }
    }
}

struct MyItem: Identifiable {
    let id = UUID()
    let name: String
    let description: String
}
