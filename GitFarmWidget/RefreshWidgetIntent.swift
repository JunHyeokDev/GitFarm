//
//  RefreshWidgetIntent.swift
//  GitFarm
//
//  Created by Jun Hyeok Kim on 8/5/24.
//

import AppIntents
import WidgetKit

struct RefreshWidgetIntent: AppIntent {
    static var title: LocalizedStringResource = "Refresh Widget"
    static var description = IntentDescription("Refreshes the widget data from the app.")
    
    

    @MainActor
    func perform() async throws -> some IntentResult {
        // Set loading state to true
        if let userDefaults = UserDefaults(suiteName: "group.com.Jun.GitFarm.FarmWidget") {
            userDefaults.set(true, forKey: "widgetIsLoading")
        }
        print("Button is tapped and reached perform()")
        // Request data refresh and wait for completion
        let success = await refreshData()
        print("Button is tapped and reached refreshData()")

        // Set loading state to false
        if let userDefaults = UserDefaults(suiteName: "group.com.Jun.GitFarm.FarmWidget") {
            userDefaults.set(false, forKey: "widgetIsLoading")
        }
        
        // Request widget update
        WidgetCenter.shared.reloadAllTimelines()
        print("Button is tapped and about to return .result()")
        return .result()
    }
    
    
    private func refreshData() async -> Bool {
        await withCheckedContinuation { continuation in
            var observer: NSObjectProtocol?
            
            let timeout = DispatchWorkItem {
                if let observer = observer {
                    NotificationCenter.default.removeObserver(observer)
                }
                continuation.resume(returning: false)
            }
            
            observer = NotificationCenter.default.addObserver(
                forName: Notification.Name("WidgetDataRefreshCompleted"),
                object: nil,
                queue: .main
            ) { _ in
                timeout.cancel()
                if let observer = observer {
                    NotificationCenter.default.removeObserver(observer)
                }
                continuation.resume(returning: true)
            }
            
            NotificationCenter.default.post(
                name: Notification.Name("RefreshWidgetDataFromApp"),
                object: nil
            )
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0, execute: timeout) // 10초 탕
        }
    }
}
