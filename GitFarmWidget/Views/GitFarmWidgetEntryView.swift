//
//  GitFarmWidgetEntryView.swift
//  GitFarmWidgetExtension
//
//  Created by Jun Hyeok Kim on 7/30/24.
//

import SwiftUI

struct GitFarmWidgetEntryView : View {

    @Environment(\.widgetFamily) var widgetFamily
    var entry: Provider.Entry
    
    var body: some View {
        if let user = entry.user, let commitHistories = entry.commitHistories {
            switch widgetFamily {
            case.systemSmall:
                GitCommitHistoryView2(commitHistories: entry.commitHistories, user: user, columns: entry.configuration.numberOfColumns)
            case .systemMedium:
                GitCommitHistoryView2(commitHistories: entry.commitHistories, user: user, columns: entry.configuration.numberOfColumns)
            case .systemLarge:
                GitCommitHistoryView(commitHistories: entry.commitHistories, user: user, columns: entry.configuration.numberOfColumns, commitTimeStatistics: entry.commitTimeline)
            case .accessoryRectangular:
                GitCommitHistoryView(commitHistories: entry.commitHistories, user: user, columns: entry.configuration.numberOfColumns, commitTimeStatistics: entry.commitTimeline)
            default:
                Text("")
            }
        } else {
            Text("")
        }
    }
}

