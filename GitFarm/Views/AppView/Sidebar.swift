//
//  Sidebar.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 7/31/24.
//

import SwiftUI

enum Panel : Hashable {
    case myFarm
    case chart
    case social
}

struct Sidebar: View {
    
    @Binding var selection: Panel?

    var body: some View {
        
        List(selection: $selection) {
            
            Section("My Section"){
                NavigationLink(value: Panel.myFarm) {
                    Label("My Farm", systemImage: "homekit")
                }
                
                NavigationLink(value: Panel.chart) {
                    Label("Chart", systemImage: "chart.xyaxis.line")
                }
            }
            
            Section("New section") {
                NavigationLink(value: Panel.social) {
                    Label("Social", systemImage: "figure.2.arms.open")
                }
            }
        }
        #if os(macOS)
        .navigationSplitViewColumnWidth(min: 200, ideal: 200)
        #endif
    }
}
