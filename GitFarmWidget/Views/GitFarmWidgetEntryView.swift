//
//  GitFarmWidgetEntryView.swift
//  GitFarmWidgetExtension
//
//  Created by Jun Hyeok Kim on 7/30/24.
// 1su!tcasE9

import SwiftUI
import WidgetKit

struct GitFarmWidgetEntryView : View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: Provider.Entry
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if entry.isLoading {
                    improvedLoadingView
                } else if let user = entry.user, let commitHistories = entry.commitHistories {
                    contentView(user: user, commitHistories: commitHistories)
                } else {
                    Text("No data available")
                }
            }
        }
    }
    
//    private func refreshButton(geometry: GeometryProxy) -> some View {
//        Button(intent: ConfigurationAppIntent()) {
//            HStack {
//                Image(systemName: "arrow.clockwise")
//                Text("왜안되씨펄련아")
//            }
//            .padding(10)
//            .background(Color.blue.opacity(0.1))
//            .cornerRadius(10)
//        }
//        .buttonStyle(PlainButtonStyle())
//        .frame(maxWidth: .infinity)
//        .frame(height: geometry.size.height * 0.2)
//        .contentShape(Rectangle())
//    }
    
    private var loadingView: some View {
        VStack {
            ProgressView()
            Text("Updating...")
                .font(.caption)
        }
    }
    
    private var improvedLoadingView: some View {
        ZStack {
            // 배경
            LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.1), Color.blue.opacity(0.1)]), startPoint: .topLeading, endPoint: .bottomTrailing)
            
            VStack {
                // 로고 또는 아이콘 (예: SF Symbols 사용)
                Image(systemName: "leaf.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .foregroundColor(.green)
                    .offset(y:40)
                ZStack{
                    // 로딩 인디케이터
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .green))
                        .padding()
                    
                    // 텍스트
                    Text("Updating Git Farm...")
                        .font(.caption)
                        .foregroundColor(.primary)
                }
            }
        }
    }
    
    private func contentView(user: User, commitHistories: [CommitHistory]) -> some View {
        Group {
            switch widgetFamily {
            case .systemSmall:
                GitCommitHistoryView2(commitHistories: commitHistories, user: user, columns: entry.configuration.numberOfColumns)
                    .padding()
            case .systemMedium:
                GitCommitHistoryView2(commitHistories: commitHistories, user: user, columns: entry.configuration.numberOfColumns)
                    .padding()
            case .systemLarge:
                GitCommitHistoryView(commitHistories: commitHistories, user: user, columns: entry.configuration.numberOfColumns, commitTimeStatistics: entry.commitTimeline)
                    .padding()
            case .accessoryRectangular:
                GitCommitHistoryView(commitHistories: commitHistories, user: user, columns: entry.configuration.numberOfColumns, commitTimeStatistics: entry.commitTimeline)
            default:
                Text("Unsupported widget size")
            }
        }
    }
    
//    private func refreshButton(geometry: GeometryProxy) -> some View {
//        VStack {
//            Button(intent: RefreshWidgetIntent()) {
//                Image(systemName: "arrow.clockwise")
//                    .foregroundColor(.gray.opacity(0.5))
//                    .frame(width: 44, height: 44) // Increased touch area
//            }
//            .buttonStyle(PlainButtonStyle())
//            .frame(maxWidth: .infinity, alignment: .center) // Center the button
//            .contentShape(Rectangle()) // Ensure the entire area is tappable
//            Spacer()
//        }
//    }
}
