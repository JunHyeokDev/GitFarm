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
    
    var body: some View {
        VStack(alignment: .center, spacing: 5) {
            Text("Welcome to GitFarm! 👩🏻‍🌾")
                .font(.system(size: 24, weight: .bold))
            VStack(alignment: .center) {
                GitCommitHistoryView(commitHistories: viewModel.commitHistories, user: viewModel.user, columns: 17)
                    .background(colorScheme == .dark ? Color.secondary.opacity(0.3) : Color.secondary.opacity(0.1)) // 배경색 추가
                    .clipShape(RoundedRectangle(cornerRadius: 20)) // 둥글기 정도 조절
            }
        }
        .padding(.horizontal, 10)
    }
}
