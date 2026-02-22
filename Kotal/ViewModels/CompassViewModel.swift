//
//  CompassViewModel.swift
//  Kotel
//
//  Created by Idan Moshe on 22/02/2026.
//

import CoreLocation
import SwiftUI

@Observable
class CompassViewModel {
    let locationService = LocationService()

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
    }

    func formattedDistance(_ distance: CLLocationDistance) -> String {
        let isHebrew = Locale.current.language.languageCode?.identifier == "he"
        
        if distance < 1000 {
            let unit = isHebrew ? "מ'" : "m"
            return String(format: "%.0f %@", distance, unit)
        } else {
            let unit = isHebrew ? "ק\"מ" : "km"
            return String(format: "%.1f %@", distance / 1000, unit)
        }
    }
    
    func formattedDistanceSecondary(_ distance: CLLocationDistance) -> String {
        let isHebrew = Locale.current.language.languageCode?.identifier == "he"
        
        if isHebrew {
            // Show miles as secondary for Hebrew
            let milesUnit = "מייל"
            return String(format: "%.1f %@", distance / 1609.34, milesUnit)
        } else {
            // Show kilometers as secondary for English
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
