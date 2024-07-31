//
//  GitCommitCellView.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 7/27/24.
//

import SwiftUI

// MARK: - GitCommitCellView
struct GitCommitCellView : View {
    let commitHistory: CommitHistory

    let imagewidth : CGFloat = 17
    let imageheight : CGFloat = 17
    let randomNumber = Int.random(in: 1...2)

    var body: some View {
        if commitHistory.count == 0 {
            Image("seed")
                .resizable()
                .frame(width: imagewidth,height: imageheight)
        }
        else if commitHistory.count == 1 || commitHistory.count == 2 {
            Image("sprout")
                .resizable()
                .frame(width: imagewidth,height: imageheight)
        }
        else {
            Image("bigCarrot_\(randomNumber)")
                .resizable()
                .frame(width: imagewidth,height: imageheight)
        }
    }
    
    init(commitHistory: CommitHistory) {
        self.commitHistory = commitHistory
    }
}
