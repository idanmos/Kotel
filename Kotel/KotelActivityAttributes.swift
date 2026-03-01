//
//  KotelActivityAttributes.swift
//  Kotel
//
//  Created by Idan Moshe on 24/02/2026.
//

#if os(iOS)
import ActivityKit
import Foundation

/// Attributes for the Kotel Live Activity showing compass direction to the Western Wall
struct KotelActivityAttributes: ActivityAttributes {
    /// Fixed attributes that don't change during the activity
    public struct ContentState: Codable, Hashable {
        /// Current bearing to the Western Wall in degrees
        var bearingToWall: Double
        
        /// Current compass heading in degrees
        var compassHeading: Double
        
        /// Distance to the Western Wall in meters
        var distanceInMeters: Double
        
        /// Whether location is available
        var hasLocation: Bool
        
        /// Whether compass is calibrating
        var isCalibrating: Bool
        
        /// Formatted distance string
        var formattedDistance: String
        
        /// Last update timestamp
        var lastUpdate: Date
    }
    
    /// The Western Wall location (fixed attribute)
    var wallLatitude: Double = 31.7767
    var wallLongitude: Double = 35.2345
}
#endif
