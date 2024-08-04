//
//  ChartView.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 7/31/24.
//

import SwiftUI
import Charts

struct ChartView: View {
    @StateObject var viewModel: CommitHistoryViewModel
    @State private var selectedPeriod: Int = 30
    
    private let periods = [7, 30, 60]
    
    var body: some View {
        VStack(alignment : .leading) {
            HStack {
                if let avatarUrl = viewModel.user?.avatarUrl {
                    AsyncImage(url: URL(string: avatarUrl)) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    } placeholder: {
                        ProgressView()
                    }
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    if let ghID = viewModel.user?.login {
                        Text(ghID)
                    }
                    BioView(bio: viewModel.user?.bio ?? String.defaultBio() )
                }
            }
            .padding(.horizontal,10)
            
            Picker("Time Period", selection: $selectedPeriod) {
                ForEach(periods, id: \.self) { period in
                    Text("\(period) days").tag(period)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            Chart {
                ForEach(filteredCommitHistory, id: \.date) { commit in
                    BarMark(
                        x: .value("Date", commit.date, unit: .day),
                        y: .value("Commits", commit.count)
                    )
                    .foregroundStyle(Color.green.gradient)
                }
            }
            .animation(.default, value: selectedPeriod)
            
            .chartXAxis {
                AxisMarks(preset: .automatic, values: .stride(by: .day, count: xAxisStrideCount)) { value in
                    if let date = value.as(Date.self) {
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(xAxisLabel(for: date), centered: true)
                    }
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel()
                }
            }
            .frame(height: 300)
            .padding()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Total Commits:")
                        .font(.headline)
                    Text("\(totalCommits)")
                        .font(.title)
                        .foregroundColor(.green)
                        .animation(.default, value: selectedPeriod)

                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Average per day:")
                        .font(.headline)
                    Text(String(format: "%.1f", averageCommits))
                        .font(.title)
                        .foregroundColor(.blue)
                        .animation(.default, value: selectedPeriod)

                }
            }
            .padding()
        }
        .navigationTitle("Commit Activity")
    }
    
    private var filteredCommitHistory: [CommitHistory] {
        let calendar = Calendar.current
        guard let endDate = calendar.date(byAdding: .day, value: -1, to: Date()) else {
            return []
        }
        let startDate = calendar.date(byAdding: .day, value: -selectedPeriod, to: endDate) ?? endDate
        
        return viewModel.commitHistories.filter { $0.date >= startDate && $0.date <= endDate }
    }
    
    private var totalCommits: Int {
        filteredCommitHistory.reduce(0) { $0 + $1.count }
    }
    
    private var averageCommits: Double {
        Double(totalCommits) / Double(selectedPeriod)
    }
    
    private var xAxisStrideCount: Int {
        switch selectedPeriod {
        case 7:
            return 1
        case 30:
            return 7
        case 60:
            return 30
        default:
            return 1
        }
    }
    
    private func xAxisLabel(for date: Date) -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        
        switch selectedPeriod {
        case 7:
            formatter.dateFormat = "d MMM"
            return formatter.string(from: date)
        case 30:
            let startOfPeriod = calendar.date(byAdding: .day, value: -selectedPeriod, to: Date()) ?? Date()
            if let dayDiff = calendar.dateComponents([.day], from: startOfPeriod, to: date).day {
                formatter.dateFormat = "MMM"
                return "\(dayDiff) \(formatter.string(from: date))"
            }
            return ""
        case 60:
            formatter.dateFormat = "MMM"
            return formatter.string(from: date)
        default:
            formatter.dateFormat = "d MMM"
            return formatter.string(from: date)
        }
    }
}
