//
//  GitFarmWidget.swift
//  GitFarmWidget
//
//  Created by Jun Hyeok Kim on 7/30/24.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> GitFarmEntry {
        GitFarmEntry.loading()
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> GitFarmEntry {
        let isLoading = UserDefaults(suiteName: "group.com.Jun.GitFarm.FarmWidget")?.bool(forKey: "widgetIsLoading") ?? false
        if isLoading {
            return GitFarmEntry.loading()
        }
        
        let user = fetchUserInfo()
        let histories = fetchCommitHistories()
        let commitTimeline = fetchCommitStats()
        return GitFarmEntry(
            date: Date(),
            user: user,
            commitHistories: histories,
            commitTimeline: commitTimeline,
            configuration: configuration,
            isLoading: isLoading
        )
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<GitFarmEntry> {
        let isLoading = UserDefaults(suiteName: "group.com.Jun.GitFarm.FarmWidget")?.bool(forKey: "widgetIsLoading") ?? false
        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .second, value: 5, to: currentDate)!
        
        if isLoading {
            let entry = GitFarmEntry.loading()
            return Timeline(entries: [entry], policy: .after(refreshDate))
        }
        
        let user = fetchUserInfo()
        let histories = fetchCommitHistories()
        let commitTimeline = fetchCommitStats()
        let entry = GitFarmEntry(
            date: currentDate,
            user: user,
            commitHistories: histories,
            commitTimeline: commitTimeline,
            configuration: configuration,
            isLoading: isLoading
        )
        
        return Timeline(entries: [entry], policy: .after(refreshDate))
    }
    
    func fetchCommitHistories() -> [CommitHistory] {
        if let data = UserDefaults(suiteName: "group.com.Jun.GitFarm.FarmWidget")?.data(forKey: "commitHistories"),
           let decodedData = try? JSONDecoder().decode([CommitHistory].self, from: data) {
            return decodedData
        }
        return []
    }

    func fetchUserInfo() -> User {
        guard let data = UserDefaults(suiteName: "group.com.Jun.GitFarm.FarmWidget")?.data(forKey: "userInfoVM"),
              let decodedData = try? JSONDecoder().decode(User.self, from: data) else {
            return User.defaultUser
        }
        return decodedData
    }
    
    func fetchCommitStats() -> CommitTimeStatistics {
        guard let data = UserDefaults(suiteName: "group.com.Jun.GitFarm.FarmWidget")?.data(forKey: "commitTimeline"),
              let decodedData = try? JSONDecoder().decode(CommitTimeStatistics.self, from: data) else {
            return CommitTimeStatistics.defaultsInfo()
        }
        return decodedData
    }
}

struct GitFarmEntry: TimelineEntry {
    let date: Date
    let user: User?
    let commitHistories: [CommitHistory]?
    let commitTimeline: CommitTimeStatistics
    let configuration: ConfigurationAppIntent
    let isLoading: Bool
    
    static func loading() -> GitFarmEntry {
        GitFarmEntry(
            date: Date(),
            user: nil,
            commitHistories: nil,
            commitTimeline: CommitTimeStatistics.defaultsInfo(),
            configuration: ConfigurationAppIntent.defaultNumber,
            isLoading: true
        )
    }
}

struct GitFarmWidget: Widget {
    let kind: String = "GitFarmWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            GitFarmWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Git Farm Widget")
        .description("Track your GitHub activity")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .accessoryRectangular])
        .contentMarginsDisabled()
    }

}



extension ConfigurationAppIntent {
    fileprivate static var defaultNumber: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.numberOfColumns = 17
        return intent
    }
}

extension GitFarmWidget {

    // Function to get a specific description based on WidgetFamily
    private func description(for family: WidgetFamily) -> String {
        switch family {
        case .systemSmall:
            return "I'm a Minimalist 🐥"
        case .systemMedium:
            return "I like Medium size! 💼"
        case .systemLarge:
            return "Bigger display, bigger achievements! 👨‍💻"
        case .accessoryRectangular:
            return "Your GitHub contributions at a glance"
        @unknown default:
            return "Track your GitHub activity" // Default description
        }
    }
}
