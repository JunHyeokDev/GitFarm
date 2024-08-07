//
//  FollowerCell.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 8/7/24.
//

import SwiftUI

struct FollowerCell: View {
    let follower: Follower
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: follower.avatarURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
            } placeholder: {
                ProgressView()
            }
            Text(follower.login ?? "")
                .foregroundStyle(Color.accent)
                .font(.caption)
                .lineLimit(1)
        }
        .transition(.scale.combined(with: .opacity))
    }
}
