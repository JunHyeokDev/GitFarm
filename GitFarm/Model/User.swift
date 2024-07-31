//
//  User.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 7/26/24.
//

import Foundation

public struct User: Codable, Identifiable {
    public let id: Int
    public var login: String
    public var avatarUrl: String
    public var name: String?
    public var location: String?
    public var bio: String?
    public var publicRepos: Int
    public var publicGists: Int
    public var following: Int
    public var followers: Int
    public var createdAt: Date
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
        following: 0,
        followers: 0,
        createdAt: Date()
    )
}
