//
//  GitFarmApp.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 7/25/24.
//

import SwiftUI
import BackgroundTasks

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
        .backgroundTask(.appRefresh("commitDataRefresh")) {
            await performBackgroundDataRefresh()
            
        }
        #if os(macOS)
        .defaultSize(width: 1000, height: 650)
        #endif
    }
    
    func performBackgroundDataRefresh() async {
        // Implement the background refresh logic here
        await appCoordinator.refreshDataInBackground()
        scheduleNextRefresh()
    }

    func scheduleNextRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.GitFarm.refreshData")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 6 * 60 * 60) // 6 hours from now
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }

}

