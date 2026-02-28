//
//  KotelWidgetViews.swift
//  KotelWidgetExtension
//
//  Created by Idan Moshe on 24/02/2026.
//

import SwiftUI
import WidgetKit

/// Main widget entry view
struct KotelWidgetEntryView: View {
    let entry: KotelWidgetEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        case .accessoryCircular:
            CircularWidgetView(entry: entry)
        case .accessoryRectangular:
            RectangularWidgetView(entry: entry)
        case .accessoryInline:
            InlineWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

/// Small widget (Home Screen)
struct SmallWidgetView: View {
    let entry: KotelWidgetEntry

    var rotationAngle: Double {
        entry.bearingToWall - entry.compassHeading
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: "building.columns.fill")
                    .font(.caption2)
                    .foregroundStyle(.yellow.opacity(0.8))
                Text("Kotel")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.6))
            }

            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 2)
                    .frame(width: 80, height: 80)

                if entry.hasLocation {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundStyle(.yellow)
                        .rotationEffect(.degrees(rotationAngle))
                } else {
                    Image(systemName: "location.slash")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.3))
                }
            }

            if let distance = entry.formattedDistance {
                Text(distance)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            } else {
                Text("–")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.3))
            }
        }
        .padding()
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [
                    Color(red: 0.02, green: 0.02, blue: 0.1),
                    Color(red: 0.08, green: 0.06, blue: 0.18)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

/// Medium widget (Home Screen)
struct MediumWidgetView: View {
    let entry: KotelWidgetEntry

    var rotationAngle: Double {
        entry.bearingToWall - entry.compassHeading
    }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 3)
                    .frame(width: 100, height: 100)

                if entry.hasLocation {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundStyle(.yellow)
                        .rotationEffect(.degrees(rotationAngle))
                } else {
                    Image(systemName: "location.slash")
                        .font(.title2)
                        .foregroundStyle(.white.opacity(0.3))
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: "building.columns.fill")
                        .font(.caption)
                        .foregroundStyle(.yellow.opacity(0.8))
                    Text("Western Wall")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                }

                Text("הכותל המערבי")
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                    .environment(\.layoutDirection, .rightToLeft)

                if let distance = entry.formattedDistance {
                    Text(distance)
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.7))
                } else {
                    Text("Location unavailable")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.4))
                }
            }

            Spacer()
        }
        .padding()
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [
                    Color(red: 0.02, green: 0.02, blue: 0.1),
                    Color(red: 0.08, green: 0.06, blue: 0.18)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

/// Large widget (Home Screen)
struct LargeWidgetView: View {
    let entry: KotelWidgetEntry

    var rotationAngle: Double {
        entry.bearingToWall - entry.compassHeading
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 4) {
                Image(systemName: "building.columns.fill")
                    .font(.caption)
                    .foregroundStyle(.yellow.opacity(0.8))
                Text("Western Wall")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
                Spacer()
            }

            Text("הכותל המערבי")
                .font(.title.bold())
                .foregroundStyle(.white)
                .environment(\.layoutDirection, .rightToLeft)

            Spacer()

            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 4)
                    .frame(width: 180, height: 180)

                ForEach(0..<36, id: \.self) { i in
                    let isMajor = i % 9 == 0
                    Rectangle()
                        .fill(isMajor ? Color.white.opacity(0.5) : Color.white.opacity(0.2))
                        .frame(width: 2, height: isMajor ? 12 : 8)
                        .offset(y: -80)
                        .rotationEffect(.degrees(Double(i) * 10))
                }

                if entry.hasLocation {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 50, weight: .semibold))
                        .foregroundStyle(.yellow)
                        .rotationEffect(.degrees(rotationAngle))
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "location.slash")
                            .font(.title)
                            .foregroundStyle(.white.opacity(0.3))
                        Text("Location\nunavailable")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.3))
                            .multilineTextAlignment(.center)
                    }
                }
            }

            Spacer()

            if let distance = entry.formattedDistance {
                VStack(spacing: 4) {
                    Text("Distance")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.4))
                        .textCase(.uppercase)
                    Text(distance)
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                }
            }
        }
        .padding()
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [
                    Color(red: 0.02, green: 0.02, blue: 0.1),
                    Color(red: 0.08, green: 0.06, blue: 0.18)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}
