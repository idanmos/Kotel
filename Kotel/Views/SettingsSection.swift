//
//  SettingsSection.swift
//  Kotel
//
//  Created by Claude Code on 01/03/2026.
//

import SwiftUI

/// Glass effect section container for settings
struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.5))
                .textCase(.uppercase)
                .tracking(1.2)
                .padding(.leading, 4)

            if #available(iOS 26.0, macOS 26.0, watchOS 26.0, *) {
                VStack(spacing: 1) {
                    content
                }
                .glassEffect(in: .rect(cornerRadius: 16))
                .clipShape(.rect(cornerRadius: 16))
            } else {
                VStack(spacing: 1) {
                    content
                }
                .background(.ultraThinMaterial)
                .clipShape(.rect(cornerRadius: 16))
            }
        }
    }
}

#Preview("SettingsSection") {
    SettingsSection(title: "Test Section") {
        SettingsRow(icon: "star.fill", title: "Test Item", subtitle: "Subtitle")
    }
}
