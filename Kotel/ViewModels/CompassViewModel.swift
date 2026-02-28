//
//  CompassViewModel.swift
//  Kotel
//
//  Created by Idan Moshe on 22/02/2026.
//

import CoreLocation
import SwiftUI
import UIKit
import WidgetKit

@Observable
class CompassViewModel {
    let locationService = LocationService()
    #if canImport(ActivityKit)
    private(set) var liveActivityService: LiveActivityService?
    #endif

    var isLiveActivityEnabled = false

    private var lastWidgetReloadDate = Date.distantPast
    private var lastWidgetBearing: Double = .nan

    init() {
        #if canImport(ActivityKit)
        if #available(iOS 16.1, *) {
            self.liveActivityService = LiveActivityService()
        }
        #endif
    }

    static let westernWallCoordinate = CLLocationCoordinate2D(
        latitude: 31.7767,
        longitude: 35.2345
    )

    var bearingToWall: Double {
        guard let userLocation = locationService.location else { return 0 }
        return Self.bearing(
            from: userLocation.coordinate,
            to: Self.westernWallCoordinate
        )
    }

    var distanceToWall: CLLocationDistance? {
        guard let userLocation = locationService.location else { return nil }
        let wallLocation = CLLocation(
            latitude: Self.westernWallCoordinate.latitude,
            longitude: Self.westernWallCoordinate.longitude
        )
        return userLocation.distance(from: wallLocation)
    }

    var compassHeading: Double {
        guard let heading = locationService.heading else { return 0 }
        return heading.trueHeading >= 0 ? heading.trueHeading : heading.magneticHeading
    }

    var rotationAngle: Double {
        let angle = bearingToWall - compassHeading
        return angle
    }

    var headingAccuracy: Double {
        locationService.heading?.headingAccuracy ?? -1
    }

    var isCalibrating: Bool {
        headingAccuracy < 0
    }

    var hasLocation: Bool {
        locationService.location != nil
    }

    var authStatus: CLAuthorizationStatus {
        locationService.authorizationStatus
    }

    func start() {
        locationService.requestPermission()
        startAutoUpdates()
    }

    /// Automatically updates shared location data and Live Activity
    private func startAutoUpdates() {
        Task {
            print("🔄 Starting auto-updates...")
            // Wait for initial location
            while !hasLocation {
                print("⏳ Waiting for location...")
                try? await Task.sleep(for: .seconds(0.5))
            }

            print("📍 Location acquired! Starting Live Activity...")
            // Auto-start Live Activity
            startLiveActivity()

            // Keep updating
            while true {
                try? await Task.sleep(for: .seconds(2))
                await updateSharedData()
            }
        }
    }

    /// Updates shared location data for widgets and Live Activity
    private func updateSharedData() async {
        guard hasLocation, let distance = distanceToWall else { return }

        // Provide haptic feedback based on alignment
        HapticManager.shared.provideFeedbackForAlignment(angle: rotationAngle)

        // Save to App Groups for widgets
        let sharedData = SharedLocationManager.SharedLocationData(
            latitude: locationService.location?.coordinate.latitude ?? 0,
            longitude: locationService.location?.coordinate.longitude ?? 0,
            compassHeading: compassHeading,
            bearingToWall: bearingToWall,
            distanceInMeters: distance,
            formattedDistance: formattedDistance(distance),
            hasLocation: hasLocation,
            isCalibrating: isCalibrating,
            timestamp: Date()
        )
        SharedLocationManager.shared.saveLocationData(sharedData)

        // Reload widget timeline when bearing changes significantly or every 60s
        let bearingDelta = abs(bearingToWall - lastWidgetBearing)
        let timeSinceReload = Date().timeIntervalSince(lastWidgetReloadDate)
        if bearingDelta > 5 || timeSinceReload > 60 || lastWidgetBearing.isNaN {
            WidgetCenter.shared.reloadTimelines(ofKind: "KotelWidget")
            lastWidgetReloadDate = Date()
            lastWidgetBearing = bearingToWall
        }

        // Auto-update Live Activity
        await updateLiveActivity()
    }
    
    /// Starts Live Activity with current compass data
    func startLiveActivity() {
        #if canImport(ActivityKit)
        if #available(iOS 16.1, *) {
            guard hasLocation, let distance = distanceToWall else {
                print("❌ Cannot start Live Activity: hasLocation=\(hasLocation), distance=\(distanceToWall?.description ?? "nil")")
                return
            }

            print("✅ Starting Live Activity...")
            let state = LiveActivityService.createContentState(
                bearingToWall: bearingToWall,
                compassHeading: compassHeading,
                distanceInMeters: distance,
                hasLocation: hasLocation,
                isCalibrating: isCalibrating,
                formattedDistance: formattedDistance(distance)
            )

            liveActivityService?.startActivity(state: state)
            isLiveActivityEnabled = true
            print("✅ Live Activity started! isEnabled=\(isLiveActivityEnabled)")
        }
        #endif
    }
    
    /// Updates Live Activity with current compass data
    func updateLiveActivity() async {
        #if canImport(ActivityKit)
        if #available(iOS 16.1, *) {
            guard isLiveActivityEnabled, hasLocation, let distance = distanceToWall else {
                return
            }

            let state = LiveActivityService.createContentState(
                bearingToWall: bearingToWall,
                compassHeading: compassHeading,
                distanceInMeters: distance,
                hasLocation: hasLocation,
                isCalibrating: isCalibrating,
                formattedDistance: formattedDistance(distance)
            )

            await liveActivityService?.updateActivity(state: state)
        }
        #endif
    }
    
    /// Stops Live Activity
    func stopLiveActivity() {
        #if canImport(ActivityKit)
        if #available(iOS 16.1, *) {
            liveActivityService?.endActivity()
            isLiveActivityEnabled = false
        }
        #endif
    }

    func formattedDistance(_ distance: CLLocationDistance) -> String {
        let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
        
        // Hebrew and Yiddish use Hebrew script units
        let useHebrewUnits = languageCode == "he" || languageCode == "yi"
        
        if distance < 1000 {
            let unit = useHebrewUnits ? "מ'" : "m"
            return String(format: "%.0f %@", distance, unit)
        } else {
            let unit = useHebrewUnits ? "ק\"מ" : "km"
            return String(format: "%.1f %@", distance / 1000, unit)
        }
    }
    
    func formattedDistanceSecondary(_ distance: CLLocationDistance) -> String {
        let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
        
        // Hebrew and Yiddish show miles as secondary, others show km
        let useHebrewUnits = languageCode == "he" || languageCode == "yi"
        
        if useHebrewUnits {
            let milesUnit = "מייל"
            return String(format: "%.1f %@", distance / 1609.34, milesUnit)
        } else {
            return String(format: "%.1f ק\"מ", distance / 1000)
        }
    }

    private static func bearing(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) -> Double {
        let lat1 = source.latitude * .pi / 180
        let lon1 = source.longitude * .pi / 180
        let lat2 = destination.latitude * .pi / 180
        let lon2 = destination.longitude * .pi / 180

        let dLon = lon2 - lon1

        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)

        return radiansBearing * 180 / .pi
    }
}

// MARK: - Helper Classes

/// Manages sharing location data between app and widgets via App Groups
class SharedLocationManager {
    static let shared = SharedLocationManager()

    private let appGroupIdentifier = "group.com.kotel.compass"
    private let userDefaults: UserDefaults?

    private init() {
        userDefaults = UserDefaults(suiteName: appGroupIdentifier)
    }

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

    func saveLocationData(_ data: SharedLocationData) {
        guard let userDefaults = userDefaults else { return }
        if let encoded = try? JSONEncoder().encode(data) {
            userDefaults.set(encoded, forKey: "sharedLocationData")
            userDefaults.synchronize()
        }
    }

    func getLocationData() -> SharedLocationData? {
        guard let userDefaults = userDefaults,
              let data = userDefaults.data(forKey: "sharedLocationData") else {
            return nil
        }
        return try? JSONDecoder().decode(SharedLocationData.self, from: data)
    }
}

/// Manages haptic feedback for compass alignment
class HapticManager {
    static let shared = HapticManager()

    #if os(iOS)
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    #endif

    private var lastFeedbackAngle: Double = 1000
    private var isAligned: Bool = false

    private init() {
        #if os(iOS)
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        #endif
    }

    func provideFeedbackForAlignment(angle: Double) {
        #if os(iOS)
        let absoluteAngle = abs(angle)

        if absoluteAngle <= 2 {
            if !isAligned {
                impactHeavy.impactOccurred()
                isAligned = true
                lastFeedbackAngle = absoluteAngle
            }
        } else if absoluteAngle <= 5 {
            isAligned = false
            if abs(absoluteAngle - lastFeedbackAngle) >= 1 {
                impactMedium.impactOccurred()
                lastFeedbackAngle = absoluteAngle
            }
        } else if absoluteAngle <= 15 {
            isAligned = false
            if abs(absoluteAngle - lastFeedbackAngle) >= 3 {
                impactLight.impactOccurred()
                lastFeedbackAngle = absoluteAngle
            }
        } else {
            isAligned = false
            lastFeedbackAngle = absoluteAngle
        }
        #endif
    }
}
