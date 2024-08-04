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
    let commitTimeStatistics : CommitTimeStatistics

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
                CommitStatisticsView(stats: [
                    ("🐥","Early Bird", commitTimeStatistics.morning,Double(commitTimeStatistics.morning)/Double(commitTimeStatistics.totalCommits)),
                    ("🧑‍💻","Working hours", commitTimeStatistics.afternoon,Double(commitTimeStatistics.afternoon)/Double(commitTimeStatistics.totalCommits)),
                    ("🌙","Over work", commitTimeStatistics.evening,Double(commitTimeStatistics.evening)/Double(commitTimeStatistics.totalCommits)),
                    ("🧟","Coding Zombie", commitTimeStatistics.night,Double(commitTimeStatistics.night)/Double(commitTimeStatistics.totalCommits)),
                ])
                .padding(.vertical, 10)
                .padding(.horizontal,10)
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
