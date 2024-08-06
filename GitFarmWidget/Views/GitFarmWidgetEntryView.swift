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
        GeometryReader { geometry in
            ZStack {
                if entry.isLoading {
                    loadingView
                } else if let user = entry.user, let commitHistories = entry.commitHistories {
                    contentView(user: user, commitHistories: commitHistories)
                } else {
                    Text("No data available")
                }
                
                refreshButton(geometry: geometry)
            }
        }
    }
    
    private var loadingView: some View {
        VStack {
            ProgressView()
            Text("Updating...")
                .font(.caption)
        }
    }
    
    private func contentView(user: User, commitHistories: [CommitHistory]) -> some View {
        Group {
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
        }
    }
    
    private func refreshButton(geometry: GeometryProxy) -> some View {
        VStack {
            Button(intent: RefreshWidgetIntent()) {
                Color.clear
                    .frame(width: 30, height: 30)
                
            }
            .buttonStyle(.plain) // 버튼이 사라지는 마법!!
            .position(x: geometry.size.width / 2, y: 9)
            
            Spacer()
        }
    }
}
