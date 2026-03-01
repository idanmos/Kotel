//
//  KotelApp.swift
//  Kotel
//
//  Created by Idan Moshe on 22/02/2026.
//

import SwiftUI

@main
struct KotelApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
            #if os(macOS)
                .frame(width: 500, height: 700)
            #endif
        }
        #if os(macOS)
        .windowResizability(.contentSize)
        #endif

        #if os(macOS)
        Settings {
            SettingsView()
                .frame(width: 500, height: 700)
        }
        #endif
    }
}
