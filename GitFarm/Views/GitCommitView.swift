//
//  GitCommitView.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 7/27/24.
//

import SwiftUI

// MARK: - GitCommitView
struct GitCommitView<Content: View>: View {
    let columns: Int
    let rows: Int
    let size: CGSize
    let content: (Int, Int) -> Content
    
    var body: some View {
        let cellSize = calculateCellSize()
        let spacing = calculateSpacing()
        
        HStack(alignment: .center, spacing: spacing) {
            ForEach(0..<columns, id: \.self) { column in
                VStack(alignment: .center, spacing: spacing) {
                    ForEach(0..<rows, id: \.self) { row in
                        content(column, row)
                            .frame(width: cellSize, height: cellSize)
                    }
                }
            }
        }
    }
    
//    private func calculateCellSize() -> CGFloat {
//        let availableWidth = max(size.width - CGFloat(columns - 1) * calculateSpacing(), 0)
//        let availableHeight = max(size.height - CGFloat(rows - 1) * calculateSpacing() - 20, 0)
//
//        let cellWidth = availableWidth / CGFloat(columns)
//        let cellHeight = availableHeight / CGFloat(rows)
//        
//        return max(min(cellWidth, cellHeight), 1) // Ensure the cell size is at least 1
//    }
    
    private func calculateCellSize() -> CGFloat {
        let availableWidth = max(size.width - CGFloat(columns - 1) * calculateSpacing(), 0)

        // 셀의 높이를 고정 값으로 설정 (예: 20)
        let cellHeight: CGFloat = 20

        let cellWidth = availableWidth / CGFloat(columns)

        // 셀의 너비와 높이 중 작은 값을 사용하되, 최소값은 1로 설정
        return max(min(cellWidth, cellHeight), 1)
    }
    
    private func calculateSpacing() -> CGFloat {
        return 2
    }
    
    init(columns: Int, rows: Int, size: CGSize, @ViewBuilder content: @escaping (Int, Int) -> Content) {
        self.columns = columns
        self.rows = rows
        self.size = size
        self.content = content
    }
}

