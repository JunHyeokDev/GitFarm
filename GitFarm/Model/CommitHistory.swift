//
//  CommitHistory.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 7/26/24.
//

import Foundation

public struct CommitHistory : Codable {
    
    public enum GrowthStage : Int, Codable {
        case empty = 0, oneApple, twoApples, threeApples, fourApples
        
        public static func forCommitCount(_ count: Int) -> GrowthStage {
            switch count {
            case 0: return .empty
            case 1: return .oneApple
            case 2: return .twoApples
            case 3: return .threeApples
            default: return .fourApples
            }
        }
    }
    
    public let date: Date
    public let count: Int
    public let growthStage: GrowthStage
    
    public init(date: Date, count: Int, growthStage: GrowthStage) {
        self.date = date
        self.count = count
        self.growthStage = growthStage
    }
}

public struct GitHubContributionsResponse: Codable {
    public let data: GitHubData
    
    public func convertToCommitHistories() -> [CommitHistory] {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate] // 날짜만 파싱하도록 설정
        var commitHistories: [CommitHistory] = []

        for week in self.data.user.contributionsCollection.contributionCalendar.weeks {
            for day in week.contributionDays {
                if let date = dateFormatter.date(from: day.date) {
                    
                    let calendar = Calendar.current

                    let growthStage = CommitHistory.GrowthStage.forCommitCount(day.contributionCount)
                    let commit = CommitHistory(date: date, count: day.contributionCount, growthStage: growthStage)
                    commitHistories.append(commit)
                } else {
                    print("Failed to parse date: \(day.date)")
                }
            }
        }
        
        commitHistories.sort { $0.date < $1.date }
        return commitHistories
    }
}

public struct GitHubData: Codable {
    public let user: GitHubUser
}

public struct GitHubUser: Codable {
    public let contributionsCollection: ContributionsCollection
}

public struct ContributionsCollection: Codable {
    public let contributionCalendar: ContributionCalendar
}

public struct ContributionCalendar: Codable {
    public let totalContributions: Int
    public let weeks: [ContributionWeek]
}

public struct ContributionWeek: Codable {
    public let contributionDays: [ContributionDay]
}

public struct ContributionDay: Codable {
    public let contributionCount: Int
    public let date: String
}
