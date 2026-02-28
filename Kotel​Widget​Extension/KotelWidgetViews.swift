//
//  KotelWidgetViews.swift
//  KotelWidgetExtension
//
//  Created by Idan Moshe on 24/02/2026.
//

import SwiftUI
import WidgetKit
import AppIntents

// MARK: - Helpers

/// Returns a cardinal direction string for a bearing in degrees.
private func cardinalDirection(for bearing: Double) -> String {
    let normalized = ((bearing.truncatingRemainder(dividingBy: 360)) + 360)
        .truncatingRemainder(dividingBy: 360)
    switch normalized {
    case 337.5..<360, 0..<22.5: return "N"
    case 22.5..<67.5: return "NE"
    case 67.5..<112.5: return "E"
    case 112.5..<157.5: return "SE"
    case 157.5..<202.5: return "S"
    case 202.5..<247.5: return "SW"
    case 247.5..<292.5: return "W"
    case 292.5..<337.5: return "NW"
    default: return "–"
    }
}

// MARK: - Entry View

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

// MARK: - Small Widget

/// Small widget (Home Screen)
struct SmallWidgetView: View {
    let entry: KotelWidgetEntry

    var rotationAngle: Double {
        entry.bearingToWall - entry.compassHeading
    }

    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: "building.columns.fill")
                    .font(.caption2)
                    .foregroundStyle(.yellow.opacity(0.8))
                Text("Kotel", bundle: .main, comment: "Short name for the Western Wall")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.6))
            }

            ZStack {
                // Compass ring with cardinal markers
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 2)
                    .frame(width: 80, height: 80)

                ForEach(0..<4, id: \.self) { i in
                    let labels = ["N", "E", "S", "W"]
                    Text(labels[i])
                        .font(.system(size: 8, weight: .medium))
                        .foregroundStyle(.white.opacity(0.3))
                        .offset(y: -46)
                        .rotationEffect(.degrees(Double(i) * 90))
                }

                if entry.hasLocation {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(.yellow)
                        .rotationEffect(.degrees(rotationAngle))
                } else {
                    Image(systemName: "location.slash")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.3))
                }
            }

            if entry.hasLocation {
                HStack(spacing: 4) {
                    if let distance = entry.formattedDistance {
                        Text(distance)
                            .font(.caption2.bold())
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    Text(cardinalDirection(for: entry.bearingToWall))
                        .font(.caption2)
                        .foregroundStyle(.yellow.opacity(0.6))
                }
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

// MARK: - Medium Widget

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

                // Cardinal markers
                ForEach(0..<4, id: \.self) { i in
                    let labels = ["N", "E", "S", "W"]
                    Text(labels[i])
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.white.opacity(0.3))
                        .offset(y: -57)
                        .rotationEffect(.degrees(Double(i) * 90))
                }

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

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Image(systemName: "building.columns.fill")
                        .font(.caption)
                        .foregroundStyle(.yellow.opacity(0.8))
                    Text("Western Wall", bundle: .main, comment: "Title for the Western Wall")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                }

                Text(verbatim: "הכותל המערבי")
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                    .environment(\.layoutDirection, .rightToLeft)

                if entry.hasLocation {
                    HStack(spacing: 12) {
                        if let distance = entry.formattedDistance {
                            Label(distance, systemImage: "location.fill")
                                .font(.caption.bold())
                                .foregroundStyle(.white.opacity(0.7))
                        }
                        Label(
                            "\(Int(entry.bearingToWall.rounded()))° \(cardinalDirection(for: entry.bearingToWall))",
                            systemImage: "safari"
                        )
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                    }
                } else {
                    Text("Location unavailable", bundle: .main, comment: "Message when location is not available")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.4))
                }
            }

            Spacer()

            VStack(spacing: 4) {
                Button(intent: RefreshWidgetIntent()) {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                        .padding(6)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)

                Text("Refresh", bundle: .main, comment: "Button label to refresh widget")
                    .font(.system(size: 8))
                    .foregroundStyle(.white.opacity(0.4))
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

// MARK: - Large Widget

/// Large widget (Home Screen)
struct LargeWidgetView: View {
    let entry: KotelWidgetEntry

    var rotationAngle: Double {
        entry.bearingToWall - entry.compassHeading
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 4) {
                Image(systemName: "building.columns.fill")
                    .font(.caption)
                    .foregroundStyle(.yellow.opacity(0.8))
                Text("Western Wall", bundle: .main, comment: "Title for the Western Wall")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
                Spacer()
            }

            Text(verbatim: "הכותל המערבי")
                .font(.title.bold())
                .foregroundStyle(.white)
                .environment(\.layoutDirection, .rightToLeft)

            Spacer()

            ZStack {
                // Outer ring
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 4)
                    .frame(width: 180, height: 180)

                // Tick marks
                ForEach(0..<36, id: \.self) { i in
                    let isMajor = i % 9 == 0
                    Rectangle()
                        .fill(isMajor ? Color.white.opacity(0.5) : Color.white.opacity(0.2))
                        .frame(width: 2, height: isMajor ? 12 : 8)
                        .offset(y: -80)
                        .rotationEffect(.degrees(Double(i) * 10))
                }

                // Cardinal labels
                let cardinals = ["N", "E", "S", "W"]
                ForEach(0..<4, id: \.self) { i in
                    Text(cardinals[i])
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(i == 0 ? .yellow.opacity(0.8) : .white.opacity(0.4))
                        .offset(y: -66)
                        .rotationEffect(.degrees(Double(i) * 90))
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
                        Text("Location unavailable", bundle: .main, comment: "Message when location is not available")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.3))
                            .multilineTextAlignment(.center)
                    }
                }
            }

            Spacer()

            if entry.hasLocation {
                HStack {
                    VStack(spacing: 2) {
                        Text("Distance", bundle: .main, comment: "Label for distance section in widget")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.4))
                            .textCase(.uppercase)
                        if let distance = entry.formattedDistance {
                            Text(distance)
                                .font(.title3.bold())
                                .foregroundStyle(.white)
                        }
                    }

                    Spacer()

                    VStack(spacing: 2) {
                        Text("Bearing", bundle: .main, comment: "Label for bearing section in widget")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.4))
                            .textCase(.uppercase)
                        Text("\(Int(entry.bearingToWall.rounded()))° \(cardinalDirection(for: entry.bearingToWall))")
                            .font(.title3.bold())
                            .foregroundStyle(.white)
                    }

                    Spacer()

                    VStack(spacing: 2) {
                        Button(intent: RefreshWidgetIntent()) {
                            Image(systemName: "arrow.clockwise")
                                .font(.body)
                                .foregroundStyle(.white.opacity(0.6))
                                .padding(8)
                                .background(Color.white.opacity(0.1))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)

                        Text("Refresh", bundle: .main, comment: "Button label to refresh widget")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.4))
                    }
                }
                .padding(.horizontal, 8)
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
