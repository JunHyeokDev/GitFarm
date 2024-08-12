//
//  GitFarmApp.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 7/25/24.
//

import SwiftUI
#if os(iOS)
import BackgroundTasks
#endif

#if os(macOS)
import AppKit
#endif

@main
struct GitFarmApp: App {
    @StateObject private var appCoordinator = AppCoordinator()
    
    #if os(macOS)
        @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif
    
    init() {
        #if os(iOS)
        registerBackgroundTasks()
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appCoordinator)
                .environmentObject(appCoordinator.loginManager)
                #if os(iOS)
                .onOpenURL { url in
                    appCoordinator.loginManager.handleCallback(url: url)
                }
                #endif
        }
        #if os(macOS)
        .handlesExternalEvents(matching: ["*"])
        #endif
    }
    
    #if os(iOS)
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
    #endif
}


// MARK: - App delegate for MacOS

#if os(macOS)
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    @Environment(\.openURL) var openURL
    
    func application(_ application: NSApplication, open urls: [URL]) {
        if let url = urls.first {
            LoginManager.shared.handleCallback(url: url)
        }
    }
    
    private func application(_ application: NSApplication, handleOpen url: URL) -> Bool {
        LoginManager.shared.handleCallback(url: url)
        return true
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            window.delegate = self
            window.styleMask.remove(.resizable)
            window.setContentSize(NSSize(width: 1000, height: 800))
            window.minSize = NSSize(width: 1000, height: 800)
            window.maxSize = NSSize(width: 1000, height: 800)
        }
    }
    
    func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize {
        return NSSize(width: 1000, height: 800)
    }
}
#endif

