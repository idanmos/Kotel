//
//  AppSettings.swift
//  Kotel
//
//  Created by Claude Code on 01/03/2026.
//

import SwiftUI

/// Observable settings model that syncs with UserDefaults
@Observable
class AppSettings {
    static let shared = AppSettings()
    
    var showDistance: Bool {
        didSet {
            UserDefaults.standard.set(showDistance, forKey: "showDistance")
        }
    }
    
    var showCoordinates: Bool {
        didSet {
            UserDefaults.standard.set(showCoordinates, forKey: "showCoordinates")
        }
    }
    
    var hapticFeedback: Bool {
        didSet {
            UserDefaults.standard.set(hapticFeedback, forKey: "hapticFeedback")
        }
    }
    
    var useTrueNorth: Bool {
        didSet {
            UserDefaults.standard.set(useTrueNorth, forKey: "useTrueNorth")
        }
    }
    
    var distanceUnit: String {
        didSet {
            UserDefaults.standard.set(distanceUnit, forKey: "distanceUnit")
        }
    }
    
    private init() {
        // Load from UserDefaults or use defaults
        self.showDistance = UserDefaults.standard.object(forKey: "showDistance") as? Bool ?? true
        self.showCoordinates = UserDefaults.standard.object(forKey: "showCoordinates") as? Bool ?? false
        self.hapticFeedback = UserDefaults.standard.object(forKey: "hapticFeedback") as? Bool ?? true
        self.useTrueNorth = UserDefaults.standard.object(forKey: "useTrueNorth") as? Bool ?? true
        self.distanceUnit = UserDefaults.standard.string(forKey: "distanceUnit") ?? "auto"
    }
}
