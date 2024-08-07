//
//  EntryView.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 7/26/24.
//

import SwiftUI

struct EntryView: View {
    @ObservedObject var commitHistoryViewModel: CommitHistoryViewModel
    @ObservedObject var userDataViewModel : UserDataViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .center, spacing: 5) {
            
            Text("Welcome to GitFarm! 👩🏻‍🌾")
                .foregroundStyle(Color.accent)
                .font(.system(size: 24, weight: .bold))
            VStack(alignment: .center) {
                GitCommitHistoryView(commitHistories: commitHistoryViewModel.commitHistories, user: commitHistoryViewModel.user, columns: 17, commitTimeStatistics: userDataViewModel.commitStats ?? CommitTimeStatistics.defaultsInfo())
                    .padding(.all, 10) // <-- 여기에 패딩 추가 (모든 방향에 10씩)
                    .background(colorScheme == .dark ? Color.secondary.opacity(0.3) : Color.secondary.opacity(0.1)) // 배경색 추가
                    .clipShape(RoundedRectangle(cornerRadius: 20)) // 둥글기 정도 조절
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
        }
        .padding(.horizontal, 10)
    }
}
