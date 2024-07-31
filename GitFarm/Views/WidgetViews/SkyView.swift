//
//  SkyView.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 7/30/24.
//

import SwiftUI

struct SkyView: View {
    
    let cloudImages = ["cloud1", "cloud2", "cloud3", "cloud4"]
    let sunCenterX: CGFloat = 25 / 2
    let safeRadius: CGFloat = 30
    
    var body: some View {
        ZStack {
            Image("sun")
                .resizable()
                .frame(width: 25, height: 25)
                .zIndex(1)
                .offset(y:5)
            
            // 왼쪽에 13개 구름 배치
            ForEach(0..<13, id: \.self) { index in
                Image(cloudImages.randomElement()!)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .offset(x: CGFloat.generateRandomXOffset(
                        range: -207...0,
                        sunCenterX: sunCenterX,
                        safeRadius: safeRadius
                    ), y: CGFloat.random(in: 0...12.5))
            }
            
            // 오른쪽에 13개 구름 배치
            ForEach(0..<13, id: \.self) { index in
                Image(cloudImages.randomElement()!)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .offset(x: CGFloat.generateRandomXOffset(
                        range: 0...207,
                        sunCenterX: sunCenterX,
                        safeRadius: safeRadius
                    ), y: CGFloat.random(in: 0...12.5))
            }
        }
        .offset(y:-10)
    }
}
