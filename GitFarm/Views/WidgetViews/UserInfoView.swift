//
//  UserInfoView.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 7/27/24.
//

import SwiftUI

// MARK: - UserInfoView
struct UserInfoView: View {
    let user: User
    let parentWidth: CGFloat
    @Environment(\.colorScheme) var colorScheme
    
    init(user: User, parentWidth: CGFloat) {
        self.user = user
        self.parentWidth = parentWidth
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            UsernameView(username: user.login)
            BioView(bio: user.bio ?? String.defaultBio())
            LocationView(location: user.location ?? "No location yet!")
            FollowersView(followers: user.followers, following: user.following)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .frame(width: parentWidth)
        .background(colorScheme == .dark ? Color.accentColor.opacity(0.1) : Color.accentColor.opacity(0.05)) // 배경색 추가
        .cornerRadius(20)
    }
}

struct UsernameView: View {
    let username: String
    
    var body: some View {
        Text(username)
            .font(.system(size: 18, weight: .bold, design: .monospaced))
            .foregroundColor(.primary)
    }
}

struct BioView: View {
    let bio: String
    
    var body: some View {
        Text(bio)
            .font(.system(size: 12, design: .monospaced))
            .foregroundColor(.secondary)
            .lineLimit(2)
    }
}

struct LocationView: View {
    let location: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "location.circle.fill")
                .foregroundColor(.primary)
            Text(location)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.secondary)
        }
    }
}

struct FollowersView: View {
    let followers: Int
    let following: Int
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "person.2.fill")
                .foregroundColor(.primary)
            Text("\(followers)")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
            Text("followers")
                .font(.system(size: 10, design: .monospaced))
            Text("|")
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.secondary)
            Text("\(following)")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
            Text("following")
                .font(.system(size: 10, design: .monospaced))
        }
        .foregroundColor(.secondary)
    }
}

struct DevelopmentDateView: View {
    let createdAt: Date
    
    var body: some View {
        Text("develop since \(formattedDate(createdAt))")
            .font(.system(size: 10, design: .monospaced))
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: date)
    }
}

