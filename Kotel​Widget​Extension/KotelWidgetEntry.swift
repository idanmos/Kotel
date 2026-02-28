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

    /// Persistent reference so CLLocationManager stays alive across getTimeline calls.
    private let locationFetcher = WidgetLocationFetcher()

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
        print("[Widget] getTimeline called")

        // Try shared data first (freshest when app is running)
        let sharedData = SharedLocationManager.shared.getLocationData()
        if let sharedData {
            let age = Date().timeIntervalSince(sharedData.timestamp)
            print("[Widget] Shared data found: hasLocation=\(sharedData.hasLocation), age=\(Int(age))s")
            if sharedData.hasLocation, age < 600 {
                print("[Widget] Using shared data (fresh)")
                let entries = generateTimelineEntries(from: sharedData)
                // Use .atEnd to refresh when the last entry expires
                completion(Timeline(entries: entries, policy: .atEnd))
                return
            } else {
                print("[Widget] Shared data stale or no location")
            }
        } else {
            print("[Widget] No shared data found in App Groups")
        }

        // Fallback: fetch location directly
        print("[Widget] Starting direct location fetch...")
        Task {
            let entry = await fetchLocationEntry()
            print("[Widget] Direct fetch result: hasLocation=\(entry.hasLocation), distance=\(entry.distanceInMeters?.description ?? "nil")")
            let entries = generateTimelineEntries(from: entry)
            completion(Timeline(entries: entries, policy: .atEnd))
        }
    }

    /// Generates timeline entries for periodic widget updates.
    /// - Parameter data: Source data (either SharedLocationData or KotelWidgetEntry)
    /// - Returns: Array of timeline entries with staggered update times
    private func generateTimelineEntries(from sharedData: SharedLocationManager.SharedLocationData) -> [KotelWidgetEntry] {
        var entries: [KotelWidgetEntry] = []
        let now = Date()

        // Generate entries for the next 2 hours, updating every 5 minutes
        // Note: iOS may throttle updates based on battery and usage patterns
        for minuteOffset in stride(from: 0, to: 120, by: 5) {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: now) ?? now
            let entry = KotelWidgetEntry(
                date: entryDate,
                bearingToWall: sharedData.bearingToWall,
                compassHeading: sharedData.compassHeading,
                distanceInMeters: sharedData.distanceInMeters,
                hasLocation: true,
                formattedDistance: sharedData.formattedDistance
            )
            entries.append(entry)
        }

        return entries
    }

    /// Generates timeline entries from a single entry (overload for fallback case).
    private func generateTimelineEntries(from entry: KotelWidgetEntry) -> [KotelWidgetEntry] {
        var entries: [KotelWidgetEntry] = []
        let now = Date()

        // Generate entries for the next 2 hours, updating every 5 minutes
        for minuteOffset in stride(from: 0, to: 120, by: 5) {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: now) ?? now
            let updatedEntry = KotelWidgetEntry(
                date: entryDate,
                bearingToWall: entry.bearingToWall,
                compassHeading: entry.compassHeading,
                distanceInMeters: entry.distanceInMeters,
                hasLocation: entry.hasLocation,
                formattedDistance: entry.formattedDistance
            )
            entries.append(updatedEntry)
        }

        return entries
    }

    /// Fetches location directly via CLLocationManager and builds an entry.
    private func fetchLocationEntry() async -> KotelWidgetEntry {
        guard let location = await locationFetcher.fetchLocation() else {
            print("[Widget] fetchLocationEntry: no location returned")
            return KotelWidgetEntry(
                date: Date(),
                bearingToWall: 0,
                compassHeading: 0,
                distanceInMeters: nil,
                hasLocation: false,
                formattedDistance: nil
            )
        }

        let bearing = Self.bearing(from: location.coordinate, to: Self.westernWallCoordinate)
        let wallLocation = CLLocation(
            latitude: Self.westernWallCoordinate.latitude,
            longitude: Self.westernWallCoordinate.longitude
        )
        let distance = location.distance(from: wallLocation)
        print("[Widget] fetchLocationEntry: bearing=\(bearing), distance=\(distance)")

        // Also save to shared storage for next refresh
        let sharedData = SharedLocationManager.SharedLocationData(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            compassHeading: 0,
            bearingToWall: bearing,
            distanceInMeters: distance,
            formattedDistance: formatDistance(distance),
            hasLocation: true,
            isCalibrating: false,
            timestamp: Date()
        )
        SharedLocationManager.shared.saveLocationData(sharedData)

        return KotelWidgetEntry(
            date: Date(),
            bearingToWall: bearing,
            compassHeading: 0,
            distanceInMeters: distance,
            hasLocation: true,
            formattedDistance: formatDistance(distance)
        )
    }

    private func formatDistance(_ distance: Double) -> String {
        if distance < 1000 {
            return String(format: "%.0f m", distance)
        } else {
            return String(format: "%.1f km", distance / 1000)
        }
    }

    /// Calculates the bearing from one coordinate to another.
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
