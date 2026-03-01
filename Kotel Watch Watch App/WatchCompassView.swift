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
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    AngularGradient(
                        colors: [
                            .blue.opacity(0.1),
                            .blue.opacity(0.3),
                            .cyan.opacity(0.2),
                            .blue.opacity(0.1)
                        ],
                        center: .center
                    ),
                    lineWidth: 1.5
                )
                .frame(width: 130, height: 130)

            Circle()
                .stroke(Color.white.opacity(0.06), lineWidth: 20)
                .frame(width: 120, height: 120)

            ForEach(0..<36, id: \.self) { i in
                let isMajor = i % 9 == 0
                let isMedium = i % 3 == 0
                Rectangle()
                    .fill(isMajor ? Color.white.opacity(0.7) : Color.white.opacity(isMedium ? 0.3 : 0.12))
                    .frame(width: isMajor ? 1.5 : 1, height: isMajor ? 10 : (isMedium ? 6 : 4))
                    .offset(y: -60)
                    .rotationEffect(.degrees(Double(i) * 10))
            }

            let cardinals = [("N", 0.0), ("E", 90.0), ("S", 180.0), ("W", 270.0)]
            ForEach(cardinals, id: \.0) { label, angle in
                Text(label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(label == "N" ? .red.opacity(0.9) : .white.opacity(0.5))
                    .offset(y: -50)
                    .rotationEffect(.degrees(angle))
            }
        }
    }
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
                // Glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: isActive
                                ? [Color(red: 1.0, green: 0.85, blue: 0.3).opacity(0.6), .clear]
                                : [.gray.opacity(0.3), .clear],
                            center: .center,
                            startRadius: 4,
                            endRadius: 10
                        )
                    )
                    .frame(width: 20, height: 20)
                    .blur(radius: 1)

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
