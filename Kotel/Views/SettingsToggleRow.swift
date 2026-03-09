//
//  SettingsToggleRow.swift
//  Kotel
//
//  Created by Claude Code on 01/03/2026.
//

import SwiftUI

/// Settings row with a toggle switch
struct SettingsToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String?
    @Binding var isOn: Bool

    init(icon: String, title: String, subtitle: String? = nil, isOn: Binding<Bool>) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self._isOn = isOn
    }

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.yellow.opacity(0.8))
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundStyle(.white)

                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.yellow)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.02))
    }
}

#Preview("SettingsToggleRow") {
    SettingsToggleRow(icon: "hand.tap.fill", title: "Haptic Feedback", isOn: .constant(true))
}
