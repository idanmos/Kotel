//
//  DirectionNeedle.swift
//  Kotel
//
//  Created by Idan Moshe on 22/02/2026.
//

import SwiftUI

struct DirectionNeedle: View {
    let rotationDegrees: Double
    let isActive: Bool
    var scale: CGFloat = 1

    var body: some View {
        ZStack {
            // Soft glow behind the needle - directional
            if isActive {
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [.yellow.opacity(0.2), .yellow.opacity(0.08), .clear],
                            center: .center,
                            startRadius: 10,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 140)
                    .offset(y: -35)
                    .blur(radius: 8)
                    .rotationEffect(.degrees(rotationDegrees))
            }

            // Elegant arrow needle starting from center
            ArrowNeedleShape()
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
                .frame(width: 24, height: 110)
                .shadow(color: isActive ? .yellow.opacity(0.5) : .clear, radius: 8, x: 0, y: 0)
                .shadow(color: isActive ? .orange.opacity(0.3) : .clear, radius: 4, x: 0, y: -2)
                .shadow(color: .black.opacity(0.25), radius: 3, x: 0, y: 2)
                .offset(y: -12)
                .rotationEffect(.degrees(rotationDegrees))

            // Center pivot with layered design
            ZStack {
                // Outer glow ring
                Circle()
                    .fill(
                        RadialGradient(
                            colors: isActive
                                ? [Color(red: 1.0, green: 0.85, blue: 0.3).opacity(0.6), .clear]
                                : [.gray.opacity(0.4), .clear],
                            center: .center,
                            startRadius: 8,
                            endRadius: 16
                        )
                    )
                    .frame(width: 32, height: 32)
                    .blur(radius: 2)

                // Main center circle
                Circle()
                    .fill(
                        RadialGradient(
                            colors: isActive
                                ? [Color(red: 1.0, green: 0.9, blue: 0.4), Color(red: 0.95, green: 0.65, blue: 0.15)]
                                : [.gray.opacity(0.6), .gray.opacity(0.4)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 12
                        )
                    )
                    .frame(width: 24, height: 24)
                    .shadow(color: isActive ? .orange.opacity(0.5) : .clear, radius: 6)
                    .shadow(color: .black.opacity(0.3), radius: 3)

                // Inner highlight ring
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                    .frame(width: 18, height: 18)

                // Center dot
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.white.opacity(0.95), .white.opacity(0.7)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 4
                        )
                    )
                    .frame(width: 8, height: 8)
                    .shadow(color: .black.opacity(0.2), radius: 1, y: 1)
            }
        }
        .scaleEffect(scale)
    }
}

#Preview("DirectionNeedle") {
    DirectionNeedle(rotationDegrees: 0, isActive: true)
}

/// Beautiful arrow needle shape starting from center
struct ArrowNeedleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let centerY = rect.maxY * 0.6
        let tipY = rect.minY
        let baseWidth: CGFloat = rect.width * 0.35
        let arrowHeadWidth: CGFloat = rect.width * 0.8
        let arrowHeadLength: CGFloat = rect.height * 0.25

        // Start from bottom center (at the center circle)
        path.move(to: CGPoint(x: rect.midX, y: centerY))

        // Left side of shaft going up
        path.addLine(to: CGPoint(x: rect.midX - baseWidth / 2, y: centerY))
        path.addLine(to: CGPoint(x: rect.midX - baseWidth / 2, y: tipY + arrowHeadLength))

        // Left side of arrow head
        path.addLine(to: CGPoint(x: rect.midX - arrowHeadWidth / 2, y: tipY + arrowHeadLength))

        // Arrow tip
        path.addLine(to: CGPoint(x: rect.midX, y: tipY))

        // Right side of arrow head
        path.addLine(to: CGPoint(x: rect.midX + arrowHeadWidth / 2, y: tipY + arrowHeadLength))

        // Right side of shaft going down
        path.addLine(to: CGPoint(x: rect.midX + baseWidth / 2, y: tipY + arrowHeadLength))
        path.addLine(to: CGPoint(x: rect.midX + baseWidth / 2, y: centerY))

        path.closeSubpath()
        return path
    }
}
