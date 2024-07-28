//
//  GitFarmApp.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 7/25/24.
//

import SwiftUI

@main
struct GitFarmApp: App {
    let persistenceController = PersistenceController.shared

    @StateObject private var loginManager = LoginManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(loginManager)
                .onOpenURL { url in
                    loginManager.handleCallback(url: url)
                }
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        #if os(macOS)
        .defaultSize(width: 1000, height: 650)
        #endif
    }
}
