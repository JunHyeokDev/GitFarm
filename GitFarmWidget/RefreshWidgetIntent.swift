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

    func perform() async throws -> some IntentResult {
        // Send a notification to the app to refresh data
        NotificationCenter.default.post(name: Notification.Name("RefreshWidgetDataFromApp"), object: nil)
        
        // Request widget update
        WidgetCenter.shared.reloadAllTimelines()
        
        return .result()
    }
}
