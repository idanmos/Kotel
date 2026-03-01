//
//  WatchCompassView.swift
//  Kotel Watch Watch App
//
//  Created by Idan Moshe on 24/02/2026.
//

import SwiftUI

struct WatchCompassView: View {
    let rotationDegrees: Double
    let isActive: Bool

    var body: some View {
        ZStack {
            WatchCompassRing()

            WatchDirectionNeedle(rotationDegrees: rotationDegrees, isActive: isActive)
        }
        .frame(width: 140, height: 140)
    }
}

#Preview {
    WatchCompassView(rotationDegrees: 0, isActive: true)
}

struct WatchCompassRing: View {
    private static let amberGold = Color(red: 0.95, green: 0.75, blue: 0.2)

    var body: some View {
        ZStack {
            // Outer ring with warm gradient
            Circle()
                .stroke(
                    AngularGradient(
                        colors: [
                            amberGold.opacity(0.15),
                            .white.opacity(0.08),
                            amberGold.opacity(0.12),
                            .white.opacity(0.06),
                            amberGold.opacity(0.15)
                        ],
                        center: .center
                    ),
                    lineWidth: 1.5
                )
                .frame(width: 130, height: 130)

            // Subtle inner ring fill
            Circle()
                .stroke(Color.white.opacity(0.05), lineWidth: 20)
                .frame(width: 120, height: 120)

            // 72 tick marks (every 5°)
            ForEach(0..<72, id: \.self) { i in
                let degrees = Double(i) * 5
                let isMajor = Int(degrees) % 45 == 0
                let isMedium = Int(degrees) % 15 == 0

                Rectangle()
                    .fill(
                        isMajor
                            ? Color.white.opacity(0.8)
                            : Color.white.opacity(isMedium ? 0.35 : 0.12)
                    )
                    .frame(
                        width: isMajor ? 1.5 : 1,
                        height: isMajor ? 10 : (isMedium ? 7 : 4)
                    )
                    .offset(y: -60)
                    .rotationEffect(.degrees(degrees))
            }

            // 8 direction labels
            let directions: [(String, Double)] = [
                ("N", 0), ("NE", 45), ("E", 90), ("SE", 135),
                ("S", 180), ("SW", 225), ("W", 270), ("NW", 315)
            ]
            ForEach(directions, id: \.0) { label, angle in
                let isCardinal = ["N", "E", "S", "W"].contains(label)
                Text(label)
                    .font(.system(size: isCardinal ? 10 : 7, weight: .semibold))
                    .foregroundStyle(
                        label == "N"
                            ? Self.amberGold
                            : .white.opacity(isCardinal ? 0.5 : 0.35)
                    )
                    .offset(y: -49)
                    .rotationEffect(.degrees(angle))
            }
        }
    }

    private var amberGold: Color { Self.amberGold }
}

#Preview {
    WatchCompassRing()
}

struct WatchDirectionNeedle: View {
    let rotationDegrees: Double
    let isActive: Bool

    var body: some View {
        ZStack {
            // Directional glow for Watch
            if isActive {
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [.yellow.opacity(0.25), .yellow.opacity(0.1), .clear],
                            center: .center,
                            startRadius: 5,
                            endRadius: 30
                        )
                    )
                    .frame(width: 60, height: 70)
                    .offset(y: -18)
                    .blur(radius: 4)
                    .rotationEffect(.degrees(rotationDegrees))
            }

            // Elegant arrow for Watch
            WatchArrowNeedleShape()
                .fill(
                    LinearGradient(
                        colors: isActive
                            ? [
                                Color(red: 1.0, green: 0.95, blue: 0.4),
                                Color(red: 1.0, green: 0.85, blue: 0.2),
                                Color(red: 0.98, green: 0.7, blue: 0.15),
                                Color(red: 0.92, green: 0.55, blue: 0.1)
                              ]
                            : [.gray.opacity(0.6), .gray.opacity(0.4), .gray.opacity(0.3)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 14, height: 55)
                .shadow(color: isActive ? .yellow.opacity(0.5) : .clear, radius: 4)
                .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
                .offset(y: -6)
                .rotationEffect(.degrees(rotationDegrees))

            // Center pivot for Watch
            ZStack {
                // Softer outer glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: isActive
                                ? [Color(red: 1.0, green: 0.85, blue: 0.3).opacity(0.5), .clear]
                                : [.gray.opacity(0.25), .clear],
                            center: .center,
                            startRadius: 3,
                            endRadius: 14
                        )
                    )
                    .frame(width: 28, height: 28)
                    .blur(radius: 2)

                // Main circle
                Circle()
                    .fill(
                        RadialGradient(
                            colors: isActive
                                ? [Color(red: 1.0, green: 0.9, blue: 0.4), Color(red: 0.95, green: 0.65, blue: 0.15)]
                                : [.gray.opacity(0.6), .gray.opacity(0.4)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 7
                        )
                    )
                    .frame(width: 14, height: 14)
                    .shadow(color: isActive ? .orange.opacity(0.4) : .clear, radius: 3)

                // Highlight
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    .frame(width: 10, height: 10)

                // Center dot
                Circle()
                    .fill(.white.opacity(0.9))
                    .frame(width: 5, height: 5)
            }
        }
    }
}

/// Watch-sized arrow needle shape
struct WatchArrowNeedleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let centerY = rect.maxY * 0.6
        let tipY = rect.minY
        let baseWidth: CGFloat = rect.width * 0.35
        let arrowHeadWidth: CGFloat = rect.width * 0.85
        let arrowHeadLength: CGFloat = rect.height * 0.28

        // Start from bottom center
        path.move(to: CGPoint(x: rect.midX, y: centerY))

        // Left shaft
        path.addLine(to: CGPoint(x: rect.midX - baseWidth / 2, y: centerY))
        path.addLine(to: CGPoint(x: rect.midX - baseWidth / 2, y: tipY + arrowHeadLength))

        // Left arrow head
        path.addLine(to: CGPoint(x: rect.midX - arrowHeadWidth / 2, y: tipY + arrowHeadLength))

        // Tip
        path.addLine(to: CGPoint(x: rect.midX, y: tipY))

        // Right arrow head
        path.addLine(to: CGPoint(x: rect.midX + arrowHeadWidth / 2, y: tipY + arrowHeadLength))

        // Right shaft
        path.addLine(to: CGPoint(x: rect.midX + baseWidth / 2, y: tipY + arrowHeadLength))
        path.addLine(to: CGPoint(x: rect.midX + baseWidth / 2, y: centerY))

        path.closeSubpath()
        return path
    }
}

#Preview {
    WatchDirectionNeedle(rotationDegrees: 0, isActive: true)
}
