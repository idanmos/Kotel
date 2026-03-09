//
//  WatchDirectionNeedle.swift
//  Kotel Watch Watch App
//
//  Created by Idan Moshe on 24/02/2026.
//

import SwiftUI

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
