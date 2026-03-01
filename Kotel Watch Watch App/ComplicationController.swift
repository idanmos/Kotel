//
//  ComplicationController.swift
//  Kotel Watch Watch App
//
//  Created by Claude Code on 01/03/2026.
//

import SwiftUI
import WidgetKit
import CoreLocation

/// Widget bundle for all watch complications
@main
struct KotelWatchWidgetBundle: WidgetBundle {
    var body: some Widget {
        KotelComplicationWidget()
    }
}

/// Main complication widget for watch face
struct KotelComplicationWidget: Widget {
    let kind: String = "KotelComplication"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ComplicationProvider()) { entry in
            ComplicationEntryView(entry: entry)
        }
        .configurationDisplayName(Text("Kotel Direction", bundle: .main, comment: "Complication display name"))
        .description(Text("Shows direction to the Western Wall", bundle: .main, comment: "Complication description"))
        .supportedFamilies([
            .accessoryCircular,
            .accessoryCorner,
            .accessoryInline,
            .accessoryRectangular
        ])
    }
}

/// Timeline entry for complications
struct ComplicationEntry: TimelineEntry {
    let date: Date
    let direction: Double
    let distance: CLLocationDistance?
    let isActive: Bool
}

/// Provides timeline entries for complications
struct ComplicationProvider: TimelineProvider {
    func placeholder(in context: Context) -> ComplicationEntry {
        ComplicationEntry(
            date: Date(),
            direction: 0,
            distance: 5000,
            isActive: true
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (ComplicationEntry) -> Void) {
        let entry = ComplicationEntry(
            date: Date(),
            direction: 0,
            distance: 5000,
            isActive: true
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ComplicationEntry>) -> Void) {
        let currentDate = Date()
        let viewModel = CompassViewModel()
        
        let entry = ComplicationEntry(
            date: currentDate,
            direction: viewModel.rotationAngle,
            distance: viewModel.distanceToWall,
            isActive: viewModel.hasLocation
        )
        
        // Update every 5 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
}

/// View for complication entry
struct ComplicationEntryView: View {
    let entry: ComplicationEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .accessoryCircular:
            circularView
        case .accessoryCorner:
            cornerView
        case .accessoryInline:
            inlineView
        case .accessoryRectangular:
            rectangularView
        default:
            circularView
        }
    }
    
    private var circularView: some View {
        ZStack {
            AccessoryWidgetBackground()
            
            VStack(spacing: 2) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 20, weight: .bold))
                    .rotationEffect(.degrees(entry.direction))
                    .foregroundStyle(entry.isActive ? .yellow : .gray)
                
                if let distance = entry.distance {
                    Text(formatDistanceShort(distance))
                        .font(.system(size: 8, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    private var cornerView: some View {
        ZStack {
            Image(systemName: "arrow.up")
                .font(.system(size: 16, weight: .bold))
                .rotationEffect(.degrees(entry.direction))
                .foregroundStyle(entry.isActive ? .yellow : .gray)
        }
    }
    
    private var inlineView: some View {
        HStack(spacing: 4) {
            Image(systemName: "arrow.up")
                .rotationEffect(.degrees(entry.direction))
            
            if let distance = entry.distance {
                Text(formatDistanceShort(distance))
            } else {
                Text("Kotel", bundle: .main, comment: "Inline complication text")
            }
        }
    }
    
    private var rectangularView: some View {
        HStack(spacing: 8) {
            Image(systemName: "arrow.up")
                .font(.system(size: 24, weight: .bold))
                .rotationEffect(.degrees(entry.direction))
                .foregroundStyle(entry.isActive ? .yellow : .gray)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: "הכותל")
                    .font(.system(size: 14, weight: .bold, design: .serif))
                    .environment(\.layoutDirection, .rightToLeft)
                
                if let distance = entry.distance {
                    Text(formatDistance(distance))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(4)
    }
    
    private func formatDistanceShort(_ distance: CLLocationDistance) -> String {
        let measurement = Measurement(value: distance, unit: UnitLength.meters)
        
        if distance >= 1000 {
            let km = measurement.converted(to: .kilometers)
            return String(format: "%.0fkm", km.value)
        } else {
            return String(format: "%.0fm", measurement.value)
        }
    }
    
    private func formatDistance(_ distance: CLLocationDistance) -> String {
        let measurement = Measurement(value: distance, unit: UnitLength.meters)
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .short
        formatter.numberFormatter.maximumFractionDigits = distance < 1000 ? 0 : 1
        
        if distance >= 1000 {
            return formatter.string(from: measurement.converted(to: .kilometers))
        } else {
            return formatter.string(from: measurement)
        }
    }
}

#Preview("Circular", as: .accessoryCircular) {
    KotelComplicationWidget()
} timeline: {
    ComplicationEntry(date: Date(), direction: 45, distance: 5234, isActive: true)
    ComplicationEntry(date: Date(), direction: 90, distance: 1500, isActive: true)
}

#Preview("Corner", as: .accessoryCorner) {
    KotelComplicationWidget()
} timeline: {
    ComplicationEntry(date: Date(), direction: 45, distance: 5234, isActive: true)
}

#Preview("Inline", as: .accessoryInline) {
    KotelComplicationWidget()
} timeline: {
    ComplicationEntry(date: Date(), direction: 45, distance: 5234, isActive: true)
}

#Preview("Rectangular", as: .accessoryRectangular) {
    KotelComplicationWidget()
} timeline: {
    ComplicationEntry(date: Date(), direction: 45, distance: 5234, isActive: true)
}
