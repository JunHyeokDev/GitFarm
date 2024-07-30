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
            case .systemMedium:
                GitCommitHistoryView(commitHistories: entry.commitHistories, user: user, columns: entry.configuration.numberOfColumns)
            case .systemLarge:
                GitCommitHistoryView(commitHistories: entry.commitHistories, user: user, columns: entry.configuration.numberOfColumns)
            case .accessoryRectangular:
                GitCommitHistoryView(commitHistories: entry.commitHistories, user: user, columns: entry.configuration.numberOfColumns)
            default:
                Text("")
            }
        } else {
            Text("")
        }
    }
}

