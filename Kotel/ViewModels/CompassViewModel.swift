//
//  CompassViewModel.swift
//  Kotel
//
//  Created by Idan Moshe on 22/02/2026.
//

import CoreLocation
import SwiftUI
#if os(iOS)
import UIKit
#elseif os(watchOS)
import WatchKit
#elseif os(macOS)
import AppKit
#endif

@Observable
class CompassViewModel {
    let locationService = LocationService()
    let settings = AppSettings.shared

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
        
        // Respect the useTrueNorth setting
        if settings.useTrueNorth && heading.trueHeading >= 0 {
            return heading.trueHeading
        } else {
            return heading.magneticHeading
        }
    }

    var rotationAngle: Double {
        var angle = bearingToWall - compassHeading
        angle = angle.truncatingRemainder(dividingBy: 360)
        if angle > 180 { angle -= 360 }
        if angle < -180 { angle += 360 }
        return angle
    }

    var headingAccuracy: Double {
        locationService.heading?.headingAccuracy ?? -1
    }

    var isCalibrating: Bool {
        guard locationService.heading != nil else { return false }
        return headingAccuracy < 0
    }

    var hasLocation: Bool {
        locationService.location != nil
    }

    var authStatus: CLAuthorizationStatus {
        locationService.authorizationStatus
    }

    private var isStarted = false

    func start() {
        guard !isStarted else { return }
        isStarted = true
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
                try? await Task.sleep(for: .seconds(0.3))
                await updateHaptics()
            }
        }
    }

    /// Provides haptic feedback based on alignment
    private func updateHaptics() async {
        guard hasLocation else { return }
        if settings.hapticFeedback {
            HapticManager.shared.provideFeedbackForAlignment(angle: rotationAngle)
        }
    }

    /// Formats distance using the user's preferred unit system
    func formattedDistance(_ distance: CLLocationDistance) -> String {
        let measurement = Measurement(value: distance, unit: UnitLength.meters)
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .short

        switch settings.distanceUnit {
        case "metric":
            formatter.unitOptions = .providedUnit
            if distance >= 1000 {
                formatter.numberFormatter.maximumFractionDigits = 1
                return formatter.string(from: measurement.converted(to: .kilometers))
            } else {
                formatter.numberFormatter.maximumFractionDigits = 0
                return formatter.string(from: measurement)
            }
        case "imperial":
            formatter.unitOptions = .providedUnit
            let miles = measurement.converted(to: .miles)
            if miles.value < 0.1 {
                formatter.numberFormatter.maximumFractionDigits = 0
                return formatter.string(from: measurement.converted(to: .feet))
            } else {
                formatter.numberFormatter.maximumFractionDigits = 1
                return formatter.string(from: miles)
            }
        default:
            // Automatic — let the formatter pick the best unit for the locale
            formatter.unitOptions = .naturalScale
            formatter.numberFormatter.maximumFractionDigits = distance < 1000 ? 0 : 1
            return formatter.string(from: measurement)
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
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    #endif

    private var lastFeedbackAngle: Double = 1000
    private var lastFeedbackTime: Date = .distantPast

    private init() {
        #if os(iOS)
        impactMedium.prepare()
        impactHeavy.prepare()
        notificationGenerator.prepare()
        #endif
    }

    func provideFeedbackForAlignment(angle: Double) {
        let absoluteAngle = abs(angle)
        let now = Date()
        let elapsed = now.timeIntervalSince(lastFeedbackTime)

        #if os(iOS)
        if absoluteAngle <= 3 {
            // Dead center — strongest feedback (notification vibration)
            if elapsed >= 0.3 {
                notificationGenerator.notificationOccurred(.success)
                notificationGenerator.prepare()
                lastFeedbackTime = now
                lastFeedbackAngle = absoluteAngle
            }
        } else if absoluteAngle <= 8 {
            // Very close — heavy impact at full intensity
            if elapsed >= 0.35 {
                impactHeavy.impactOccurred(intensity: 1.0)
                impactHeavy.prepare()
                lastFeedbackTime = now
                lastFeedbackAngle = absoluteAngle
            }
        } else if absoluteAngle <= 15 {
            // Getting close — strong medium impact
            if elapsed >= 0.4 {
                impactMedium.impactOccurred(intensity: 0.8)
                impactMedium.prepare()
                lastFeedbackTime = now
                lastFeedbackAngle = absoluteAngle
            }
        } else if absoluteAngle <= 25 {
            // Approaching — gentle nudge
            if elapsed >= 0.5 {
                impactMedium.impactOccurred(intensity: 0.5)
                impactMedium.prepare()
                lastFeedbackTime = now
                lastFeedbackAngle = absoluteAngle
            }
        } else {
            lastFeedbackAngle = absoluteAngle
        }
        #elseif os(watchOS)
        if absoluteAngle <= 3 {
            // Dead center — strongest watchOS haptic
            if elapsed >= 0.3 {
                WKInterfaceDevice.current().play(.notification)
                lastFeedbackTime = now
                lastFeedbackAngle = absoluteAngle
            }
        } else if absoluteAngle <= 8 {
            // Very close
            if elapsed >= 0.35 {
                WKInterfaceDevice.current().play(.success)
                lastFeedbackTime = now
                lastFeedbackAngle = absoluteAngle
            }
        } else if absoluteAngle <= 15 {
            // Getting close
            if elapsed >= 0.4 {
                WKInterfaceDevice.current().play(.directionUp)
                lastFeedbackTime = now
                lastFeedbackAngle = absoluteAngle
            }
        } else if absoluteAngle <= 25 {
            // Approaching
            if elapsed >= 0.5 {
                WKInterfaceDevice.current().play(.click)
                lastFeedbackTime = now
                lastFeedbackAngle = absoluteAngle
            }
        } else {
            lastFeedbackAngle = absoluteAngle
        }
        #elseif os(macOS)
        // No haptic feedback on macOS
        _ = absoluteAngle
        #endif
    }
}
