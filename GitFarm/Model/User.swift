//
//  User.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 7/26/24.
//

import Foundation

public struct User: Codable, Identifiable, Equatable {
    public let id: Int
    let login: String
    let avatarUrl: String
    let name: String?
    let location: String?
    let bio: String?
    let publicRepos: Int
    let publicGists: Int
    let htmlUrl: String
    var following: Int
    var followers: Int
    let createdAt: Date
}

extension User {
    public static let defaultUser = User(
        id: 0,
        login: "DefaultUser",
        avatarUrl: "",
        name: nil,
        location: nil,
        bio: nil,
        publicRepos: 0,
        publicGists: 0,
        htmlUrl: "",
        following: 0,
        followers: 0,
        createdAt: Date()
    )
}
