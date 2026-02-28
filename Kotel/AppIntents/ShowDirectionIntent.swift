//
//  ShowDirectionIntent.swift
//  Kotel
//
//  Created by Idan Moshe on 24/02/2026.
//

import AppIntents
import SwiftUI

/// App Intent for showing direction to Western Wall
struct ShowDirectionIntent: AppIntent {
    static var title: LocalizedStringResource = "Show Direction to Kotel"
    static var description = IntentDescription("Opens the compass pointing to the Western Wall in Jerusalem")
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        return .result()
    }
}

/// App Shortcuts configuration
struct KotelShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ShowDirectionIntent(),
            phrases: [
                "Show me \(.applicationName)",
                "Open \(.applicationName)",
                "Point me to Kotel in \(.applicationName)"
            ],
            shortTitle: "Show Direction",
            systemImageName: "location.north.circle.fill"
        )
    }
}
