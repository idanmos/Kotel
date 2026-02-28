//
//  SharedLocationManager.swift
//  Kotel
//
//  Created by Idan Moshe on 24/02/2026.
//

import Foundation
import CoreLocation

/// Manages sharing location data between app and widgets via App Groups
class SharedLocationManager {
    static let shared = SharedLocationManager()

    private let appGroupIdentifier = "group.com.kotal.compass"
    private let userDefaults: UserDefaults?

    private init() {
        userDefaults = UserDefaults(suiteName: appGroupIdentifier)
    }

    /// Shared location data structure
    struct SharedLocationData: Codable {
        let latitude: Double
        let longitude: Double
        let compassHeading: Double
        let bearingToWall: Double
        let distanceInMeters: Double
        let formattedDistance: String
        let hasLocation: Bool
        let isCalibrating: Bool
        let timestamp: Date
    }

    /// Saves current location data for widgets to access
    /// - Parameter data: The location data to save
    func saveLocationData(_ data: SharedLocationData) {
        guard let userDefaults = userDefaults else { return }

        if let encoded = try? JSONEncoder().encode(data) {
            userDefaults.set(encoded, forKey: "sharedLocationData")
            userDefaults.synchronize()
        }
    }

    /// Retrieves the latest location data saved by the app
    /// - Returns: The latest location data, or nil if none available
    func getLocationData() -> SharedLocationData? {
        guard let userDefaults = userDefaults,
              let data = userDefaults.data(forKey: "sharedLocationData") else {
            return nil
        }

        return try? JSONDecoder().decode(SharedLocationData.self, from: data)
    }

    /// Clears stored location data
    func clearLocationData() {
        userDefaults?.removeObject(forKey: "sharedLocationData")
        userDefaults?.synchronize()
    }
}
