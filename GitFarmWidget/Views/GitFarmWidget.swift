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
//        GitFarmEntry(date: Date(), configuration: ConfigurationAppIntent())
        return GitFarmEntry.loading()
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> GitFarmEntry {
        let numColumns = configuration.numberOfColumns
        let user = fetchUserInfo()
        let histories = fetchCommitHistories()
        
        return GitFarmEntry(
            date: Date(),
            user: user,
            commitHistories: histories,
            configuration: configuration
        )
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<GitFarmEntry> {
        var entries: [GitFarmEntry] = []
        let currentDate = Date()
        let user = fetchUserInfo()
        let histories = fetchCommitHistories()

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = GitFarmEntry(
                date: entryDate,
                user: user,
                commitHistories: histories,
                configuration: configuration
            )
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
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
}

struct GitFarmEntry: TimelineEntry {
    let date: Date
    let user: User?
    let commitHistories: [CommitHistory]?
    let configuration: ConfigurationAppIntent
    
    static func loading() -> GitFarmEntry {
        GitFarmEntry(date: Date(), user: nil, commitHistories: nil, configuration: ConfigurationAppIntent.defaultNumber)
    }
}

struct GitFarmWidget: Widget {
    let kind: String = "GitFarmWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            GitFarmWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}

extension ConfigurationAppIntent {
    fileprivate static var defaultNumber: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.numberOfColumns = 17
        return intent
    }
}
