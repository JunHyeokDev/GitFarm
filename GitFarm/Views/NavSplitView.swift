//
//  NavSplitView.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 7/25/24.
//

import SwiftUI

struct NavSplitView: View {
    
    @EnvironmentObject var commitHistoryViewModel: CommitHistoryViewModel
    //@State private var selectedCategory: Category? // 기본값 설정
    @State private var selection: Panel? = Panel.myFarm
    @State private var path = NavigationPath()


    var body: some View {
        NavigationSplitView {
            Sidebar(selection: $selection)
        } detail: {
            NavigationStack(path: $path) {
                DetailView(selection: $selection, commitHistoryViewModel: commitHistoryViewModel)
            }
        }
    }
}

struct CategoryDetailView: View {
    @ObservedObject var commitHistoryViewModel: CommitHistoryViewModel
    let category: Category
    
    var body: some View {
        List(category.items) { item in
            NavigationLink(destination: MyItemDetailView(commitHistoryViewModel: commitHistoryViewModel, item: item)) {
                Text(item.name)
            }
        }
        .navigationTitle(category.title)
    }
}

struct MyItemDetailView: View {
    @ObservedObject var commitHistoryViewModel: CommitHistoryViewModel
    let item: MyItem
    
    var body: some View {
        VStack {
            EntryView(viewModel: commitHistoryViewModel)
        }
        .navigationTitle(item.name)
    }
}

enum Category: String, CaseIterable, Identifiable {
    case status, myFarm
    var id: Self { self }
    
    var title: String {
      switch self {
      case .myFarm:
        return "My Farm"
      default:
        return rawValue.split(separator: " ").map { $0.capitalized }.joined(separator: " ")
      }
    }
    
    var items: [MyItem] {
        switch self {
        case .status:
            return [MyItem(name: "MyFarm", description: "A sweet, edible fruit produced by an apple tree.")]
        case .myFarm:
            return [MyItem(name: "Carrot", description: "A tapering orange-colored root eaten as a vegetable.")]
        }
    }
}

struct MyItem: Identifiable {
    let id = UUID()
    let name: String
    let description: String
}
