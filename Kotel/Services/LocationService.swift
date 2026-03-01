//
//  LocationService.swift
//  Kotel
//
//  Created by Idan Moshe on 22/02/2026.
//

import CoreLocation
import SwiftUI

/// LocationService manages location and heading updates for the compass app.
@Observable
class LocationService: NSObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    var location: CLLocation?
    var heading: CLHeading?
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var locationError: String?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.headingFilter = 1
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    /// Starts location and heading updates
    func startUpdates() {
        manager.startUpdatingLocation()
        #if os(iOS) || os(watchOS)
        manager.startUpdatingHeading()
        #endif
    }

    /// Stops all location and heading updates
    func stopUpdates() {
        manager.stopUpdatingLocation()
        #if os(iOS) || os(watchOS)
        manager.stopUpdatingHeading()
        #endif
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            self.location = locations.last
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        Task { @MainActor in
            self.heading = newHeading
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.authorizationStatus = manager.authorizationStatus
            
            #if os(macOS)
            let isAuthorized = manager.authorizationStatus == .authorizedAlways
            #else
            let isAuthorized = manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways
            #endif
            if isAuthorized {
                self.startUpdates()
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.locationError = error.localizedDescription
            print("Location error: \(error.localizedDescription)")
        }
    }
}
