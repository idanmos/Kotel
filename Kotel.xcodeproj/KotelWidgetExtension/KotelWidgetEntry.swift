//
//  KotelWidgetEntry.swift
//  KotelWidgetExtension
//
//  Created by Idan Moshe on 24/02/2026.
//

import WidgetKit
import CoreLocation

/// Timeline entry for the Kotel widget
struct KotelWidgetEntry: TimelineEntry {
    let date: Date
    let bearingToWall: Double
    let compassHeading: Double
    let distanceInMeters: Double?
    let hasLocation: Bool
    let formattedDistance: String?
}

/// Provider for the Kotel widget timeline
struct KotelWidgetProvider: TimelineProvider {
    static let westernWallCoordinate = CLLocationCoordinate2D(
        latitude: 31.7767,
        longitude: 35.2345
    )
    
    func placeholder(in context: Context) -> KotelWidgetEntry {
        KotelWidgetEntry(
            date: Date(),
            bearingToWall: 45,
            compassHeading: 0,
            distanceInMeters: 5000,
            hasLocation: true,
            formattedDistance: "5.0 km"
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (KotelWidgetEntry) -> Void) {
        let entry = KotelWidgetEntry(
            date: Date(),
            bearingToWall: 45,
            compassHeading: 0,
            distanceInMeters: 5000,
            hasLocation: true,
            formattedDistance: "5.0 km"
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<KotelWidgetEntry>) -> Void) {
        let currentDate = Date()
        
        // Create entry with current data
        let entry = createEntry(for: currentDate)
        
        // Refresh every 5 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
    
    private func createEntry(for date: Date) -> KotelWidgetEntry {
        // Fetch real location data from App Groups
        if let sharedData = SharedLocationManager.shared.getLocationData() {
            return KotelWidgetEntry(
                date: date,
                bearingToWall: sharedData.bearingToWall,
                compassHeading: sharedData.compassHeading,
                distanceInMeters: sharedData.distanceInMeters,
                hasLocation: sharedData.hasLocation,
                formattedDistance: sharedData.formattedDistance
            )
        }

        // Fallback if no data available
        return KotelWidgetEntry(
            date: date,
            bearingToWall: 0,
            compassHeading: 0,
            distanceInMeters: nil,
            hasLocation: false,
            formattedDistance: nil
        )
    }
    
    private func formatDistance(_ distance: Double) -> String {
        if distance < 1000 {
            return String(format: "%.0f m", distance)
        } else {
            return String(format: "%.1f km", distance / 1000)
        }
    }
}
