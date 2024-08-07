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
    
    init() {
        registerBackgroundTasks()
    }
    
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
    
    func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.Jun.GitFarm.refreshWidget", using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
    }
    
    func handleAppRefresh(task: BGAppRefreshTask) {
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        Task {
            await appCoordinator.refreshWidgetData()
            task.setTaskCompleted(success: true)
        }
        
        scheduleBackgroundRefresh()
    }
    
    func scheduleBackgroundRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.Jun.GitFarm.refreshWidget")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutes from now
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
    
//    func performBackgroundDataRefresh() async {
//        // Implement the background refresh logic here
//        await appCoordinator.refreshDataInBackground()
//        scheduleNextRefresh()
//    }
//
//    func scheduleNextRefresh() {
//        let request = BGAppRefreshTaskRequest(identifier: "com.GitFarm.refreshData")
//        request.earliestBeginDate = Date(timeIntervalSinceNow: 6 * 60 * 60) // 6 hours from now
//        
//        do {
//            try BGTaskScheduler.shared.submit(request)
//        } catch {
//            print("Could not schedule app refresh: \(error)")
//        }
//    }

}

