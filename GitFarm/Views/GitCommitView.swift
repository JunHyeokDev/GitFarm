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
    
    private func calculateCellSize() -> CGFloat {
        let totalWidth = size.width - CGFloat(columns - 1) * 2
        let totalHeight = size.height - CGFloat(rows - 1) * 2 - 20
        return min(totalWidth / CGFloat(columns), totalHeight / CGFloat(rows))
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

