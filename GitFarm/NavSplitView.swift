//
//  NavSplitView.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 7/25/24.
//

import SwiftUI

struct NavSplitView: View {
    
    @EnvironmentObject var commitHistoryViewModel: CommitHistoryViewModel
    @State private var selectedCategory: Category? = .status // 기본값 설정

    
    var body: some View {
        NavigationSplitView {
            List(Category.allCases, selection: $selectedCategory) { category in
                NavigationLink(value: category) {
                    Text(category.title)
                }
            }
            .navigationTitle("Hello \(commitHistoryViewModel.login)! Welcome to GitFarm👩🏻‍🌾")
        } detail: {
            NavigationStack {
                if let selectedCategory {
                    CategoryDetailView(commitHistoryViewModel: commitHistoryViewModel, category: selectedCategory)
                }
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
            return [MyItem(name: "Apple", description: "A sweet, edible fruit produced by an apple tree."),
                    MyItem(name: "Banana", description: "A long curved fruit which grows in clusters and has soft pulpy flesh and yellow skin when ripe.")]
        case .myFarm:
            return [MyItem(name: "Carrot", description: "A tapering orange-colored root eaten as a vegetable."),
                    MyItem(name: "Broccoli", description: "An edible green plant in the cabbage family.")]
        }
    }
}

struct MyItem: Identifiable {
    let id = UUID()
    let name: String
    let description: String
}
