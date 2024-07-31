//
//  GitCommitHistoryView.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 7/27/24.
//

import SwiftUI

// MARK: - GitCommitHistoryView
struct GitCommitHistoryView: View {
    var commitHistories: [CommitHistory]?
    var user: User?
    let columns: Int
    let rows = 7

    var body: some View {
        let commitHistorySet = CommitHistoryViewModel.commitHistorySet(with: commitHistories ?? [], columnsCount: columns)

        GeometryReader { geometry in
            VStack(spacing: 0) {
                SkyView()
                    .frame(height: geometry.size.height * 0.12)
                    .offset(y:-5)
                
                GitCommitView(columns: columns, rows: rows, size: CGSize(width: geometry.size.width, height: geometry.size.height * 0.40)) { column, row in
                    Group {
                        if let commitHistory = commitHistorySet.element(at: row)?.element(at: column) {
                            GitCommitCellView(commitHistory: commitHistory)
                        } else {
                            Color.clear
                                .frame(height: 17)
                        }
                    }
                }
                .frame(height: geometry.size.height * 0.40)
                
                FenceView(parentWidth: geometry.size.width)
                    .frame(height: geometry.size.height * 0.15)
                    .offset(y:-10)

                UserInfoView(user: user ?? User.defaultUser, parentWidth: geometry.size.width)
                    .frame(height: geometry.size.height * 0.35)
                    .offset(y:-15)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

// MARK: - GitCommitHistoryView
struct GitCommitHistoryView2: View {
    var commitHistories: [CommitHistory]?
    var user: User?
    let columns: Int
    let rows = 7

    var body: some View {
        let commitHistorySet = CommitHistoryViewModel.commitHistorySet(with: commitHistories ?? [], columnsCount: columns)

        GeometryReader { geometry in
            VStack(spacing: 0) {
                SkyView()
                    .frame(height: geometry.size.height * 0.10)
                    .offset(y:-3)
                ZStack {
                    GitCommitView(columns: columns, rows: rows, size: CGSize(width: geometry.size.width, height: geometry.size.height)) { column, row in
                        if let commitHistory = commitHistorySet.element(at: row)?.element(at: column) {
                            GitCommitCellView(commitHistory: commitHistory)
                        } else {
                            Color.clear
                        }
                    }
                }
                .frame(height: geometry.size.height)
                
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}
