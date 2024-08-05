//
//  GitFarmWidgetEntryView.swift
//  GitFarmWidgetExtension
//
//  Created by Jun Hyeok Kim on 7/30/24.
//

//import SwiftUI
//
//struct GitFarmWidgetEntryView : View {
//
//    @Environment(\.widgetFamily) var widgetFamily
//    var entry: Provider.Entry
//    
//    var body: some View {
//        if let user = entry.user, let commitHistories = entry.commitHistories {
//            switch widgetFamily {
//            case.systemSmall:
//                GitCommitHistoryView2(commitHistories: entry.commitHistories, user: user, columns: entry.configuration.numberOfColumns)
//            case .systemMedium:
//                GitCommitHistoryView2(commitHistories: entry.commitHistories, user: user, columns: entry.configuration.numberOfColumns)
//            case .systemLarge:
//                GitCommitHistoryView(commitHistories: entry.commitHistories, user: user, columns: entry.configuration.numberOfColumns, commitTimeStatistics: entry.commitTimeline)
//            case .accessoryRectangular:
//                GitCommitHistoryView(commitHistories: entry.commitHistories, user: user, columns: entry.configuration.numberOfColumns, commitTimeStatistics: entry.commitTimeline)
//            default:
//                Text("")
//            }
//        } else {
//            Text("")
//        }
//    }
//}

import SwiftUI
import WidgetKit

struct GitFarmWidgetEntryView : View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: Provider.Entry
    
    var body: some View {
        if let user = entry.user, let commitHistories = entry.commitHistories {
            GeometryReader { geometry in
                ZStack {
                    switch widgetFamily {
                    case .systemSmall:
                        GitCommitHistoryView2(commitHistories: commitHistories, user: user, columns: entry.configuration.numberOfColumns)
                    case .systemMedium:
                        GitCommitHistoryView2(commitHistories: commitHistories, user: user, columns: entry.configuration.numberOfColumns)
                    case .systemLarge:
                        GitCommitHistoryView(commitHistories: commitHistories, user: user, columns: entry.configuration.numberOfColumns, commitTimeStatistics: entry.commitTimeline)
                    case .accessoryRectangular:
                        GitCommitHistoryView(commitHistories: commitHistories, user: user, columns: entry.configuration.numberOfColumns, commitTimeStatistics: entry.commitTimeline)
                    default:
                        Text("Unsupported widget size")
                    }
                    
                    // Refresh button
                    VStack {
                        Button(intent: RefreshWidgetIntent()) {
                            Text("")
                                .frame(width: 30, height: 30)
                        }
                        .buttonStyle(.plain)
                        .clipShape(Circle())
                        .position(x: geometry.size.width / 2, y: 10)
                        
                        Spacer()
                    }
                }
            }
        } else {
            Text("No data available")
        }
    }
}
