//
//  Array+Ext.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 7/26/24.
//

import Foundation

extension Array {
    
    func element(at index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
    
    func slice(into size: Int) -> [[Element]] {
        stride(from: startIndex, to: endIndex, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, endIndex)])
        }
    }

}
