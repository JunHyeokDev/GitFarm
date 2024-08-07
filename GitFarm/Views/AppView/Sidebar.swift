//
//  Sidebar.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 7/31/24.
//

import SwiftUI

enum Panel: Hashable {
    case myFarm
    case chart
    case social
}

struct Sidebar: View {
    @Binding var selection: Panel?
    
    var body: some View {
        List(selection: $selection) {
            Section(header: CustomSectionHeader(title: "My Section")) {
                CustomNavigationLink(title: "My Farm", icon: "🏡", color: .green, panel: .myFarm, selection: $selection)
                CustomNavigationLink(title: "Chart", icon: "📊", color: .blue, panel: .chart, selection: $selection)
            }
            
            Section(header: CustomSectionHeader(title: "New Section")) {
                CustomNavigationLink(title: "Social", icon: "👥", color: .purple, panel: .social, selection: $selection)
            }
        }
        .listStyle(SidebarListStyle())
        #if os(macOS)
        .navigationSplitViewColumnWidth(min: 200, ideal: 200)
        #endif
    }
}

struct CustomNavigationLink: View {
    let title: String
    let icon: String
    let color: Color
    let panel: Panel
    @Binding var selection: Panel?
    @Environment(\.colorScheme) var colorScheme  // 현재 색상 스키마를 가져옵니다.
    
    var body: some View {
        NavigationLink(value: panel) {
            HStack {
                Text(icon)
                    .font(.system(size: 24))
                    .frame(width: 36, height: 36)
                    .background(color.opacity(0.2))
                    .cornerRadius(8)
                
                Text(title)
                    .font(.custom("Avenir-Medium", size: 18))
                    .foregroundColor(Color.theme.accent)
            }
            .padding(.vertical, 4)
        }
    }
}

struct CustomSectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.custom("Avenir-Heavy", size: 14))
            .foregroundColor(Color.theme.secondaryText)
            .padding(.top, 8)
    }
}
