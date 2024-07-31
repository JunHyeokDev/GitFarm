//
//  DetailView.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 7/31/24.
//

import SwiftUI

struct DetailView: View {
    
    @Binding var selection: Panel?
    @ObservedObject var commitHistoryViewModel: CommitHistoryViewModel

    var body: some View {
        switch selection {
        case .myFarm:
            EntryView(viewModel: commitHistoryViewModel)
                .frame(maxWidth: 400,maxHeight: 400)
                .padding(.vertical, 10)
                .padding(.horizontal, 10)
        case .chart:
            ChartView(viewModel: commitHistoryViewModel)
        case .social:
            FollowerListView(commitHistoryViewModel: commitHistoryViewModel)
        case nil:
            Text("Nil")

        }
    }
}

