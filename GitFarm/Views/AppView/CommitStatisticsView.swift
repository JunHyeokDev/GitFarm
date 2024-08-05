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
                        .foregroundStyle(Color.accent)
                        .frame(width: 30, alignment: .leading)
                    
                    Text(stats[index].1)
                        .foregroundStyle(Color.accent)
                        .frame(width: 80, alignment: .leading)
                        .font(.system(size: 10).weight(.semibold))
                        .lineLimit(2)
                    
                    Spacer()
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.secondary.opacity(0.1))
                            
                            if stats[index].3 > 0 {
                                Rectangle()
                                    .fill(Color.green)
                                    .frame(width: geometry.size.width * stats[index].3)
                            }
                            
                            Text("\(stats[index].2) commits")
                                .font(.system(size: 10).weight(.semibold))
                                .foregroundColor(stats[index].3 > 0.5 ? .white : .accent)
                                .padding(.horizontal, 5)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    .frame(height: 20)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    
                    Text(String(format: "%.1f%%", stats[index].3 * 100))
                        .foregroundStyle(Color.accent)
                        .frame(width: 30, alignment: .trailing)
                        .font(.system(size: 8).weight(.semibold))
                }
            }
        }
        .padding()
        .background(colorScheme == .dark ? Color.accentColor.opacity(0.1) : Color.accentColor.opacity(0.05))
        .foregroundColor(.black)
        .cornerRadius(20)
    }
}
