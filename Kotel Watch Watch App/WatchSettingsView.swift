//
//  WatchSettingsView.swift
//  Kotel Watch Watch App
//
//  Created by Claude Code on 01/03/2026.
//

import SwiftUI

/// Settings view for Apple Watch
struct WatchSettingsView: View {
    @Bindable var settings: AppSettings
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle(isOn: $settings.showDistance) {
                        Label("Distance", systemImage: "ruler")
                    }
                    
                    Toggle(isOn: $settings.hapticFeedback) {
                        Label("Haptics", systemImage: "waveform")
                    }
                } header: {
                    Text("Display", bundle: .main, comment: "Settings section for display options on watch")
                }
                
                Section {
                    Toggle(isOn: $settings.useTrueNorth) {
                        Label("True North", systemImage: "location.north.fill")
                    }
                } header: {
                    Text("Compass", bundle: .main, comment: "Settings section for compass options on watch")
                }
                
                Section {
                    Picker("Units", selection: $settings.distanceUnit) {
                        Text("Auto", bundle: .main, comment: "Auto distance unit option on watch")
                            .tag("auto")
                        Text("Metric", bundle: .main, comment: "Metric distance unit option on watch")
                            .tag("metric")
                        Text("Imperial", bundle: .main, comment: "Imperial distance unit option on watch")
                            .tag("imperial")
                    }
                    .pickerStyle(.navigationLink)
                } header: {
                    Text("Units", bundle: .main, comment: "Settings section for units on watch")
                }
            }
            .navigationTitle(Text("Settings", bundle: .main, comment: "Watch settings title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done", bundle: .main, comment: "Done button on watch settings")
                    }
                }
            }
        }
    }
}

#Preview {
    WatchSettingsView(settings: AppSettings.shared)
}
