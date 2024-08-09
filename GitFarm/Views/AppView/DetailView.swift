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
    @ObservedObject var userDataViewModel: UserDataViewModel
    
    var body: some View {
        ZStack {
            // 그라디언트 배경
            LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.3), Color.blue.opacity(0.3)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading) {
                switch selection {
                case .myFarm:
                    EntryView(commitHistoryViewModel: commitHistoryViewModel, userDataViewModel: userDataViewModel)
                        .frame(maxWidth: 400, maxHeight: 400)
                case .chart:
                    ChartView(viewModel: commitHistoryViewModel)
                case .social:
                    FollowerListView(commitHistoryViewModel: commitHistoryViewModel)
                case nil:
                    Text("Nil")
                }
                Spacer()
            }
            .padding(.top) // Add some top padding to avoid overlap with the safe area
        }
    }
}

