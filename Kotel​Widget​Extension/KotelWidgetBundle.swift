//
//  KotelWidgetBundle.swift
//  KotelWidgetExtension
//
//  Created by Idan Moshe on 24/02/2026.
//

import SwiftUI
import WidgetKit

/// Main widget bundle containing all widget types
@main
struct KotelWidgetBundle: WidgetBundle {
    var body: some Widget {
        KotelWidget()
        KotelLiveActivity()
    }
}

/// Main Kotel widget (Home Screen and Lock Screen)
struct KotelWidget: Widget {
    let kind: String = "KotelWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: KotelWidgetProvider()) { entry in
            KotelWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Kotel Compass")
        .description("Shows direction and distance to the Western Wall.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}

#Preview("Small", as: .systemSmall) {
    KotelWidget()
} timeline: {
    KotelWidgetEntry(
        date: Date(),
        bearingToWall: 45,
        compassHeading: 0,
        distanceInMeters: 5000,
        hasLocation: true,
        formattedDistance: "5.0 km"
    )
}

#Preview("Medium", as: .systemMedium) {
    KotelWidget()
} timeline: {
    KotelWidgetEntry(
        date: Date(),
        bearingToWall: 45,
        compassHeading: 0,
        distanceInMeters: 5000,
        hasLocation: true,
        formattedDistance: "5.0 km"
    )
}

#Preview("Large", as: .systemLarge) {
    KotelWidget()
} timeline: {
    KotelWidgetEntry(
        date: Date(),
        bearingToWall: 45,
        compassHeading: 0,
        distanceInMeters: 5000,
        hasLocation: true,
        formattedDistance: "5.0 km"
    )
}

#Preview("Circular", as: .accessoryCircular) {
    KotelWidget()
} timeline: {
    KotelWidgetEntry(
        date: Date(),
        bearingToWall: 45,
        compassHeading: 0,
        distanceInMeters: 5000,
        hasLocation: true,
        formattedDistance: "5.0 km"
    )
}

#Preview("Rectangular", as: .accessoryRectangular) {
    KotelWidget()
} timeline: {
    KotelWidgetEntry(
        date: Date(),
        bearingToWall: 45,
        compassHeading: 0,
        distanceInMeters: 5000,
        hasLocation: true,
        formattedDistance: "5.0 km"
    )
}

#Preview("Inline", as: .accessoryInline) {
    KotelWidget()
} timeline: {
    KotelWidgetEntry(
        date: Date(),
        bearingToWall: 45,
        compassHeading: 0,
        distanceInMeters: 5000,
        hasLocation: true,
        formattedDistance: "5.0 km"
    )
}
