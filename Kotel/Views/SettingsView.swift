//
//  SettingsView.swift
//  Kotel
//
//  Created by Claude Code on 01/03/2026.
//

import SwiftUI

/// Settings view with glass effect design
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var settings = AppSettings.shared

    /// Opens the appropriate language settings for the current platform
    private func openLanguageSettings() {
        #if os(iOS)
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
        #elseif os(macOS)
        if let url = URL(string: "x-apple.systempreferences:com.apple.Language-Text") {
            NSWorkspace.shared.open(url)
        }
        #endif
    }

    /// Dynamic app version string
    private var appVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(version) (\(build))"
    }

    var body: some View {
        ZStack {
            BackgroundView()

            ScrollView {
                VStack(spacing: 20) {
                    Text("Settings", bundle: .main, comment: "Settings screen title")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 20)

                    VStack(spacing: 16) {
                        // Display Settings
                        SettingsSection(title: String(localized: "Display", bundle: .main, comment: "Settings section header for display settings")) {
                            SettingsToggleRow(
                                icon: "ruler.fill",
                                title: String(localized: "Show Distance", bundle: .main, comment: "Toggle to show distance to Kotel"),
                                isOn: $settings.showDistance
                            )

                            SettingsToggleRow(
                                icon: "location.circle.fill",
                                title: String(localized: "Show Coordinates", bundle: .main, comment: "Toggle to show current coordinates"),
                                isOn: $settings.showCoordinates
                            )

                            SettingsPickerRow(
                                icon: "arrow.left.and.right",
                                title: String(localized: "Distance Unit", bundle: .main, comment: "Distance unit preference"),
                                selection: $settings.distanceUnit,
                                options: [
                                    ("auto", String(localized: "Automatic", bundle: .main, comment: "Automatic unit selection")),
                                    ("metric", String(localized: "Metric (km)", bundle: .main, comment: "Metric units")),
                                    ("imperial", String(localized: "Imperial (mi)", bundle: .main, comment: "Imperial units"))
                                ]
                            )
                        }

                        // Compass Settings
                        SettingsSection(title: String(localized: "Compass", bundle: .main, comment: "Settings section header for compass settings")) {
                            SettingsToggleRow(
                                icon: "safari.fill",
                                title: String(localized: "Use True North", bundle: .main, comment: "Toggle between true and magnetic north"),
                                subtitle: String(localized: "Uses geographic north instead of magnetic north", bundle: .main, comment: "Explanation of true north setting"),
                                isOn: $settings.useTrueNorth
                            )

                            #if os(iOS) || os(watchOS)
                            SettingsToggleRow(
                                icon: "hand.tap.fill",
                                title: String(localized: "Haptic Feedback", bundle: .main, comment: "Toggle haptic feedback"),
                                subtitle: String(localized: "Vibrates as you point toward the Kotel", bundle: .main, comment: "Explanation of haptic feedback setting"),
                                isOn: $settings.hapticFeedback
                            )
                            #endif
                        }

                        // Language
                        SettingsSection(title: String(localized: "Language", bundle: .main, comment: "Settings section header for language settings")) {
                            Button {
                                openLanguageSettings()
                            } label: {
                                HStack(spacing: 16) {
                                    Image(systemName: "globe")
                                        .font(.title3)
                                        .foregroundStyle(.yellow.opacity(0.8))
                                        .frame(width: 32, height: 32)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("App Language", bundle: .main, comment: "Language selection setting")
                                            .font(.body)
                                            .foregroundStyle(.white)

                                        Text("Change in Settings", bundle: .main, comment: "Subtitle for language setting that opens system Settings")
                                            .font(.caption)
                                            .foregroundStyle(.white.opacity(0.5))
                                    }

                                    Spacer()

                                    Image(systemName: "arrow.up.forward.app")
                                        .font(.body)
                                        .foregroundStyle(.white.opacity(0.4))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(Color.white.opacity(0.02))
                            }
                        }

                        // About
                        SettingsSection(title: String(localized: "About", bundle: .main, comment: "Settings section header for about information")) {
                            SettingsRow(
                                icon: "building.columns.fill",
                                title: String(localized: "The Western Wall", bundle: .main, comment: "Label for the Western Wall location"),
                                subtitle: "הכותל המערבי"
                            )

                            SettingsRow(
                                icon: "location.fill",
                                title: String(localized: "Target Location", bundle: .main, comment: "Label for target location"),
                                subtitle: String(localized: "Jerusalem, Israel", bundle: .main, comment: "Location of the Western Wall")
                            )

                            SettingsRow(
                                icon: "mappin.circle.fill",
                                title: String(localized: "Coordinates", bundle: .main, comment: "Coordinates label"),
                                subtitle: "31.7767°N, 35.2345°E"
                            )
                        }

                        // App Info
                        SettingsSection(title: String(localized: "App", bundle: .main, comment: "Settings section header for app information")) {
                            SettingsRow(
                                icon: "info.circle.fill",
                                title: String(localized: "Version", bundle: .main, comment: "App version label"),
                                subtitle: appVersion
                            )
                        }
                    }
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 20)
                .frame(maxWidth: 760)
                .frame(maxWidth: .infinity)
            }
        }
    }
}

#Preview("SettingsView") {
    SettingsView()
}
