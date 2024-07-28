//
//  CGFloat+Ext.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 7/27/24.
//

import Foundation

extension CGFloat {
    // 태양과 겹치지 않는 랜덤 X 오프셋 생성 함수 (확장)
    public static func generateRandomXOffset(range: ClosedRange<CGFloat>, sunCenterX: CGFloat, safeRadius: CGFloat) -> CGFloat {
        var offsetX = CGFloat.random(in: range)
        while abs(offsetX - sunCenterX) < safeRadius {
            offsetX = CGFloat.random(in: range)
        }
        return offsetX
    }
}
