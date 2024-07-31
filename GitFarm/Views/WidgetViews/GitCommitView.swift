//
//  GitCommitView.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 7/27/24.
//

import SwiftUI
import WidgetKit

// MARK: - GitCommitView
struct GitCommitView<Content: View>: View {
    @Environment(\.widgetFamily) var family
    let columns: Int
    let rows: Int
    let size: CGSize
    let content: (Int, Int) -> Content
    
    var body: some View {
        let cellSize = calculateCellSize()
        let spacing = calculateSpacing()
        let widthSpace : CGFloat = family == .systemSmall ? 5 : spacing

        
        VStack(spacing: 3) {
            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: widthSpace) {
                    ForEach(0..<columns, id: \.self) { column in
                        content(row, column)
                            .frame(width: cellSize, height: 14)
                    }
                }
            }
        }
        .frame(maxWidth: size.width, maxHeight: size.height)
        .clipped()
    }
    
    private func calculateCellSize() -> CGFloat {
        let availableWidth = size.width - CGFloat(columns - 1) * calculateSpacing()
        let availableHeight = size.height - CGFloat(rows - 1) * calculateSpacing()

        return min(availableWidth / CGFloat(columns), availableHeight / CGFloat(rows))
    }
    
    private func calculateSpacing() -> CGFloat {
        return min(size.width, size.height) * 0.01 // 1% of the smaller dimension
    }
    
    init(columns: Int, rows: Int, size: CGSize, @ViewBuilder content: @escaping (Int, Int) -> Content) {
        self.columns = columns
        self.rows = rows
        self.size = size
        self.content = content
    }
}
