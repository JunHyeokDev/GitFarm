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
    @Environment(\.colorScheme) var colorScheme
    
    init(user: User) {
        self.user = user
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center) {
                URLImageView(urlString: user.avatarUrl, width: 200, height: 200)
            }
            .frame(maxWidth: .infinity)
            Spacer()
            
            UserInfoLineView(sfSymbol: "book.pages", text: user.bio ?? "I'm a Git Farmer! 👩🏻‍🌾🥕") // Bio
            FollowersView(followers: user.followers, following: user.following)
            UserInfoLineView(sfSymbol: "building.2", text: user.company ?? "No Company Info yet 😅") // Company
            UserInfoLineView(sfSymbol: "globe", text : "Somewhere in Earth 🌏") // location
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(colorScheme == .dark ? Color.accentColor.opacity(0.1) : Color.accentColor.opacity(0.05))
        .cornerRadius(20)
    }
}

struct UsernameView: View {
    let user: User
    
    init(user: User) {
        self.user = user
    }
    
    var body: some View {
        HStack(spacing:5 ) {
            AsyncImage(url: URL(string: user.avatarUrl)) { phase in
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
            
            Text(user.login)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundStyle(Color.accent)
        }

    }
}

struct BioView: View {
    let bio: String
    
    var body: some View {
        Text(bio)
            .font(.system(size: 12, design: .monospaced))
            .foregroundStyle(Color.accent)
            .lineLimit(2)
    }
}

struct UserInfoLineView: View {
    let sfSymbol : String
    let text : String
    
    init(sfSymbol: String, text: String) {
        self.sfSymbol = sfSymbol
        self.text = text
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: sfSymbol)
                .foregroundStyle(.primary)
                .frame(width: 15, height: 15)
            Text(text)
                .font(.system(size: 12, design: .monospaced))
                .foregroundStyle(Color.accent)
        }
    }
}

struct FollowersView: View {
    let followers: Int
    let following: Int
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.2.fill")
                .foregroundStyle(.primary)
                .frame(width: 15, height: 15)
            HStack {
                Text("\(followers)")
                    .foregroundStyle(Color.accent)
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                Text("followers")
                    .foregroundStyle(Color.accent)
                    .font(.system(size: 10, design: .monospaced))
                Text(" • ")
                    .foregroundStyle(Color.accent)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.secondary)
                Text("\(following)")
                    .foregroundStyle(Color.accent)
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                Text("following")
                    .foregroundStyle(Color.accent)
                    .font(.system(size: 10, design: .monospaced))
            }
        }
        .foregroundColor(.secondary)
    }
}
