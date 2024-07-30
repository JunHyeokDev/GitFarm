//
//  AppIntent.swift
//  GitFarmWidget
//
//  Created by Jun Hyeok Kim on 7/30/24.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("This is an example widget.")

    // An example configurable parameter.
    @Parameter(title: "Number of Columns", default: 17)
    var numberOfColumns: Int
}
