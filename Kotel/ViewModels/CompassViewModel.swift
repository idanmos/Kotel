//
//  CompassViewModel.swift
//  Kotel
//
//  Created by Idan Moshe on 22/02/2026.
//

import CoreLocation
import SwiftUI
import UIKit

@Observable
class CompassViewModel {
    let locationService = LocationService()

    init() {
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

    /// Automatically provides haptic feedback
    private func startAutoUpdates() {
        Task {
            // Wait for initial location
            while !hasLocation {
                try? await Task.sleep(for: .seconds(0.5))
            }

            // Keep updating haptic feedback
            while true {
                try? await Task.sleep(for: .seconds(2))
                await updateHaptics()
            }
        }
    }

    /// Provides haptic feedback based on alignment
    private func updateHaptics() async {
        guard hasLocation else { return }
        HapticManager.shared.provideFeedbackForAlignment(angle: rotationAngle)
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
