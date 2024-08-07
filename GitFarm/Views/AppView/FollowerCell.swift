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
            AsyncImage(url: URL(string: follower.avatarURL ?? "")) { phase in
                switch phase {
                case .empty:
                    Color.gray
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                case .failure:
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }
            Text(follower.login ?? "")
                .foregroundStyle(Color.accent)
                .font(.caption)
                .lineLimit(1)
        }
        .transition(.scale.combined(with: .opacity))
    }
}
