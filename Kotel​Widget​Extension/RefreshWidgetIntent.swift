//
//  RefreshWidgetIntent.swift
//  KotelWidgetExtension
//
//  Created by Idan Moshe on 01/03/2026.
//

import AppIntents
import WidgetKit

/// App Intent for refreshing the widget
struct RefreshWidgetIntent: AppIntent {
    static var title: LocalizedStringResource = "Refresh Kotel Widget"
    static var description = IntentDescription("Updates the widget with current location and bearing")
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult {
        // Trigger immediate widget refresh
        WidgetCenter.shared.reloadTimelines(ofKind: "KotelWidget")

        return .result()
    }
}
