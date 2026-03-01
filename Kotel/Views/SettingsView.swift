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
                        .padding(.horizontal, 20)
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

                            SettingsToggleRow(
                                icon: "hand.tap.fill",
                                title: String(localized: "Haptic Feedback", bundle: .main, comment: "Toggle haptic feedback"),
                                subtitle: String(localized: "Vibrates as you point toward the Kotel", bundle: .main, comment: "Explanation of haptic feedback setting"),
                                isOn: $settings.hapticFeedback
                            )
                        }
                        
                        // Language
                        SettingsSection(title: String(localized: "Language", bundle: .main, comment: "Settings section header for language settings")) {
                            Button {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
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

                                        Text("Change in Settings", bundle: .main, comment: "Subtitle for language setting that opens iOS Settings")
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
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

#Preview("SettingsView") {
    SettingsView()
}

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
            
            if #available(iOS 26.0, *) {
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

/// Individual settings row with icon, title, and subtitle
struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String?
    
    init(icon: String, title: String, subtitle: String? = nil) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
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
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.02))
    }
}

#Preview("SettingsRow") {
    SettingsRow(icon: "star.fill", title: "Test Item", subtitle: "Subtitle")
}

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

/// Settings row with a picker
struct SettingsPickerRow: View {
    let icon: String
    let title: String
    @Binding var selection: String
    let options: [(String, String)]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(.yellow.opacity(0.8))
                    .frame(width: 32, height: 32)
                
                Text(title)
                    .font(.body)
                    .foregroundStyle(.white)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 8)
            .background(Color.white.opacity(0.02))
            
            Picker("", selection: $selection) {
                ForEach(options, id: \.0) { value, label in
                    Text(label).tag(value)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.bottom, 14)
            .background(Color.white.opacity(0.02))
        }
    }
}

#Preview("SettingsPickerRow") {
    SettingsPickerRow(
        icon: "arrow.left.and.right",
        title: "Distance Unit",
        selection: .constant("auto"),
        options: [("auto", "Auto"), ("metric", "Metric"), ("imperial", "Imperial")]
    )
}


