//
//  LockScreenWidgetViews.swift
//  KotelWidgetExtension
//
//  Created by Idan Moshe on 24/02/2026.
//

import SwiftUI
import WidgetKit

/// Circular Lock Screen widget
struct CircularWidgetView: View {
    let entry: KotelWidgetEntry

    var rotationAngle: Double {
        entry.bearingToWall - entry.compassHeading
    }

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()

            if entry.hasLocation {
                ZStack {
                    Circle()
                        .stroke(lineWidth: 2)
                        .foregroundStyle(.secondary)

                    // Cardinal dots
                    ForEach(0..<4, id: \.self) { i in
                        Circle()
                            .fill(i == 0 ? Color.primary : Color.secondary.opacity(0.5))
                            .frame(width: 3, height: 3)
                            .offset(y: -20)
                            .rotationEffect(.degrees(Double(i) * 90))
                    }

                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .rotationEffect(.degrees(rotationAngle))
                }
            } else {
                Image(systemName: "location.slash.circle.fill")
                    .font(.title)
                    .foregroundStyle(.tertiary)
            }
        }
    }
}

/// Rectangular Lock Screen widget
struct RectangularWidgetView: View {
    let entry: KotelWidgetEntry

    var rotationAngle: Double {
        entry.bearingToWall - entry.compassHeading
    }

    var body: some View {
        HStack(spacing: 8) {
            if entry.hasLocation {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .rotationEffect(.degrees(rotationAngle))
            } else {
                Image(systemName: "location.slash")
                    .font(.title3)
                    .foregroundStyle(.tertiary)
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 3) {
                    Image(systemName: "building.columns.fill")
                        .font(.caption2)
                    Text("Kotel")
                        .font(.caption.bold())
                }

                if entry.hasLocation {
                    HStack(spacing: 6) {
                        if let distance = entry.formattedDistance {
                            Text(distance)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        Text("\(Int(entry.bearingToWall.rounded()))°")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text("Location unavailable")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
    }
}

/// Inline Lock Screen widget
struct InlineWidgetView: View {
    let entry: KotelWidgetEntry

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "building.columns.fill")

            if entry.hasLocation, let distance = entry.formattedDistance {
                Text("Kotel \(distance)")
            } else {
                Text("Kotel")
            }
        }
    }
}
