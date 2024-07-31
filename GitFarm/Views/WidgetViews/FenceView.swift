//
//  FenceView.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 7/27/24.
//

import SwiftUI

struct FenceView: View {
    
    let parentWidth : CGFloat
    
    init(parentWidth: CGFloat) {
        self.parentWidth = parentWidth
    }
    
    var body: some View {
        HStack {
            HStack(spacing: 0) {
                ForEach(0..<Int(parentWidth/14)) { _ in
                    Image("fence")
                        .resizable()
                        .scaledToFill()
                        .clipped()
                        .frame(width: 14, height: 14)
                }
            }
        }
    }
}
