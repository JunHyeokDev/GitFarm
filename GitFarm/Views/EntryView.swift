//
//  EntryView.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 7/26/24.
//

import SwiftUI

struct EntryView: View {
    @ObservedObject var viewModel: CommitHistoryViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var isLoading = true
    
    var body: some View {
        VStack(alignment: .center) {
            VStack(alignment: .center, spacing: 5) {
                Text("Welcome to GitFarm! 👩🏻‍🌾")
                    .font(.system(size: 24, weight: .bold))
//                if isLoading {
//                    ProgressView()
//                } else {
//                    VStack(alignment: .center, spacing: 5) {
//                        GitCommitHistoryView(viewModel: viewModel)
//                            .background(colorScheme == .dark ? Color.secondary.opacity(0.3) : Color.secondary.opacity(0.02)) // 배경색 추가
//                            .clipShape(RoundedRectangle(cornerRadius: 20)) // 둥글기 정도 조절
//                    }
//                }
                VStack(alignment: .center, spacing: 5) {
                    GitCommitHistoryView(viewModel: viewModel)
                        .background(colorScheme == .dark ? Color.secondary.opacity(0.3) : Color.secondary.opacity(0.02)) // 배경색 추가
                        .clipShape(RoundedRectangle(cornerRadius: 20)) // 둥글기 정도 조절
                }
            }
        }
        .frame(maxWidth: 350,minHeight: 390, maxHeight: 410)
        .padding()
//        .onAppear {
//            // 데이터 로딩이 완료되면 isLoading을 false로 설정
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                self.isLoading = false
//            }
//        }
    }
}
