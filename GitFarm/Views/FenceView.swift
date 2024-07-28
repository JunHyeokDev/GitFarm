//
//  FenceView.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 7/27/24.
//

import SwiftUI

struct FenceView: View {
    var body: some View {
        HStack {
            GeometryReader { imageGeometry in
                HStack(spacing: 0) {
                    ForEach(0..<Int(imageGeometry.size.width / 14)) { _ in
                        Image("fence")
                            .resizable()
                            .scaledToFill() // 이미지를 프레임에 꽉 채우도록 설정
                            .frame(width: 14, height: 14)
                            .clipped() // 프레임 밖으로 넘어가는 부분 잘라내기
                    }
                }
            }
        }
    }
}
