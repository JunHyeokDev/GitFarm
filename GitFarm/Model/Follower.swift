//
//  Followers.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 7/31/24.
//

import Foundation

// MARK: - Followers
struct Follower : Decodable , Identifiable, Equatable {
    let login: String?
    let id: Int?
    let nodeID: String?
    let avatarURL: String?
    let gravatarID: String?
    let url, htmlURL, followersURL: String?
    let followingURL, gistsURL, starredURL: String?
    let subscriptionsURL, organizationsURL, reposURL: String?
    let eventsURL: String?
    let receivedEventsURL: String?
    let siteAdmin: Bool?
    
    enum CodingKeys: String, CodingKey {
        case login, id, nodeID
        case avatarURL = "avatar_url"
        case gravatarID = "gravatar_id"
        case url, htmlURL = "html_url", followersURL = "followers_url"
        case followingURL = "following_url", gistsURL = "gists_url", starredURL = "starred_url"
        case subscriptionsURL = "subscriptions_url", organizationsURL = "organizations_url", reposURL = "repos_url"
        case eventsURL = "events_url"
        case receivedEventsURL = "received_events_url"
        case siteAdmin = "site_admin"
    }
}
