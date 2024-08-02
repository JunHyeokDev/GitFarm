//
//  Repository.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 8/2/24.
//

import Foundation

struct Repository: Codable, Identifiable {
    let id: Int
    let name: String
}

struct Commit: Codable {
    let sha: String
    let commit: CommitDetails
}

struct CommitDetails: Codable {
    let author: CommitAuthor
}

struct CommitAuthor: Codable {
    let date: String
}

struct CommitTimeStatistics {
    var morning: Int = 0   // 6:00 - 11:59
    var afternoon: Int = 0 // 12:00 - 17:59
    var evening: Int = 0   // 18:00 - 23:59
    var night: Int = 0     // 00:00 - 5:59
}
