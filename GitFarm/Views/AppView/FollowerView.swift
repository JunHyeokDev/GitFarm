//
//  FollowerView.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 8/1/24.
//

import SwiftUI

struct FollowerView: View {
    let username: String
    @StateObject private var viewModel = FollowerViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack {
                if viewModel.isLoading {
                    ProgressView()
                } else if let user = viewModel.user {
                    Text(user.login)
                    // 여기에 더 많은 사용자 정보를 표시할 수 있습니다.
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
}

