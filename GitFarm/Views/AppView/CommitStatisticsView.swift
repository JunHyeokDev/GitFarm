//
//  CommitStatisticsView.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 8/2/24.
//

import SwiftUI

struct CommitStatisticsView: View {
    
    @Environment(\.colorScheme) var colorScheme
    let stats: [(String, String, Int, Double)]
    
    var body: some View {
        VStack(spacing: 10) {
            ForEach(stats.indices, id: \.self) { index in
                HStack {
                    
                    Text(stats[index].0)
                        .frame(width: 30, alignment: .leading)
                    
                    Text(stats[index].1)
                        .frame(width: 80, alignment: .leading)
                    
                    Text("\(stats[index].2) commits")
                        .frame(width: 100, alignment: .leading)
                    
                    GeometryReader { geometry in
                        HStack(spacing: 0) {
                            Rectangle()
                                .fill(Color.green.opacity(0.8))
                                .frame(width: geometry.size.width * stats[index].3)
                            
                            Rectangle()
                                .fill(Color.secondary.opacity(0.1))
                        }
                    }
                    .frame(height: 20)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    
                    Text(String(format: "%.1f%%", stats[index].3 * 100))
                        .frame(width: 50, alignment: .trailing)
                }
            }
        }
        .padding()
        .background(colorScheme == .dark ? Color.accentColor.opacity(0.1) : Color.accentColor.opacity(0.05))
        .foregroundColor(.black)
        .cornerRadius(20)
    }
}
