//
//  ContentView.swift
//  Kotel
//
//  Created by Idan Moshe on 22/02/2026.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    @State private var viewModel = CompassViewModel()
    #if os(iOS)
    @State private var selectedTab = 0
    #endif

    var body: some View {
        ZStack {
            BackgroundView()

            switch viewModel.authStatus {
            case .notDetermined:
                PermissionView {
                    viewModel.start()
                }
            case .denied, .restricted:
                DeniedPermissionView()
            case .authorizedWhenInUse, .authorizedAlways:
                #if os(iOS)
                TabView(selection: $selectedTab) {
                    NavigatorContent(viewModel: viewModel)
                        .tag(0)
                        .tabItem {
                            Label(String(localized: "Compass", bundle: .main, comment: "Tab label for compass view"), systemImage: "safari.fill")
                        }

                    SettingsView()
                        .tag(1)
                        .tabItem {
                            Label(String(localized: "Settings", bundle: .main, comment: "Tab label for settings view"), systemImage: "gearshape.fill")
                        }
                }
                #else
                NavigatorContent(viewModel: viewModel)
                    .toolbar {
                        ToolbarItem(placement: .automatic) {
                            SettingsLink {
                                Label(String(localized: "Settings", bundle: .main, comment: "Toolbar button to open settings"), systemImage: "gearshape")
                            }
                        }
                    }
                #endif
            @unknown default:
                PermissionView {
                    viewModel.start()
                }
            }
        }
        .task {
            viewModel.start()
        }
        .preferredColorScheme(.dark)
    }
}

#Preview("ContentView") {
    ContentView()
}
