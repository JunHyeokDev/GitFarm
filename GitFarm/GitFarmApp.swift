//
//  GitFarmApp.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 7/25/24.
//

import SwiftUI

@main
struct GitFarmApp: App {
    @StateObject private var appCoordinator = AppCoordinator()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appCoordinator)
                .environmentObject(appCoordinator.loginManager)
                .onOpenURL { url in
                    appCoordinator.loginManager.handleCallback(url: url)
                }
        }
        #if os(macOS)
        .defaultSize(width: 1000, height: 650)
        #endif
    }
}
