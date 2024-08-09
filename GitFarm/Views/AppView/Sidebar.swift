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
    @Environment(\.colorScheme) var colorScheme
    
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
        .background(Color.clear) // 리스트 배경을 투명하게 설정
        .scrollContentBackground(.hidden) // iOS 16 이상에서 스크롤 컨텐츠 배경 숨기기
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
    @Environment(\.colorScheme) var colorScheme
    
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
        .listRowBackground(Color.clear) // 각 행의 배경을 투명하게 설정
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
