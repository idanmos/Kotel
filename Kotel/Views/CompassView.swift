//
//  CompassView.swift
//  Kotel
//
//  Created by Idan Moshe on 22/02/2026.
//

import SwiftUI

struct CompassView: View {
    let rotationDegrees: Double
    let isActive: Bool

    var body: some View {
        ZStack {
            CompassRing()

            DirectionNeedle(rotationDegrees: rotationDegrees, isActive: isActive)
        }
        .frame(width: 300, height: 300)
    }
}

#Preview("CompassView") {
    CompassView(rotationDegrees: 0, isActive: true)
}

struct CompassRing: View {
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
                    lineWidth: 2
                )
                .frame(width: 280, height: 280)

            Circle()
                .stroke(Color.white.opacity(0.06), lineWidth: 40)
                .frame(width: 260, height: 260)

            ForEach(0..<72, id: \.self) { i in
                let isMajor = i % 9 == 0
                let isMedium = i % 3 == 0
                Rectangle()
                    .fill(isMajor ? Color.white.opacity(0.7) : Color.white.opacity(isMedium ? 0.3 : 0.12))
                    .frame(width: isMajor ? 2 : 1, height: isMajor ? 16 : (isMedium ? 10 : 6))
                    .offset(y: -130)
                    .rotationEffect(.degrees(Double(i) * 5))
            }

            let cardinals = [("N", 0.0), ("E", 90.0), ("S", 180.0), ("W", 270.0)]
            ForEach(cardinals, id: \.0) { label, angle in
                Text(label)
                    .font(.system(size: 14, weight: .semibold, design: .default))
                    .foregroundStyle(label == "N" ? .red.opacity(0.9) : .white.opacity(0.5))
                    .offset(y: -108)
                    .rotationEffect(.degrees(angle))
            }
        }
    }
}

#Preview("CompassRing") {
    CompassRing()
}

struct DirectionNeedle: View {
    let rotationDegrees: Double
    let isActive: Bool

    var body: some View {
        ZStack {
            // Soft glow behind the needle tip
            if isActive {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.yellow.opacity(0.12), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 90
                        )
                    )
                    .frame(width: 180, height: 180)
                    .offset(y: -30)
                    .rotationEffect(.degrees(rotationDegrees))
            }

            // Needle body
            VStack(spacing: 0) {
                // Forward (pointing) half — golden
                NeedleShape()
                    .fill(
                        LinearGradient(
                            colors: isActive
                                ? [Color(red: 1.0, green: 0.85, blue: 0.2), Color(red: 0.95, green: 0.6, blue: 0.1)]
                                : [.gray.opacity(0.5), .gray.opacity(0.3)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 18, height: 95)
                    .shadow(color: isActive ? .orange.opacity(0.4) : .clear, radius: 6, y: -4)

                // Rear half — subtle dark
                NeedleShape()
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.12), .white.opacity(0.04)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 18, height: 95)
                    .rotationEffect(.degrees(180))
            }
            .rotationEffect(.degrees(rotationDegrees))
            .shadow(color: .black.opacity(0.3), radius: 4, y: 2)

            // Center pivot — outer ring
            Circle()
                .fill(
                    RadialGradient(
                        colors: isActive
                            ? [Color(red: 1.0, green: 0.85, blue: 0.3), Color(red: 0.9, green: 0.5, blue: 0.1)]
                            : [.gray.opacity(0.5), .gray.opacity(0.3)],
                        center: .center,
                        startRadius: 0,
                        endRadius: 10
                    )
                )
                .frame(width: 18, height: 18)
                .shadow(color: isActive ? .orange.opacity(0.3) : .clear, radius: 4)

            // Center pivot — inner dot
            Circle()
                .fill(.white.opacity(0.9))
                .frame(width: 6, height: 6)
        }
    }
}

#Preview("DirectionNeedle") {
    DirectionNeedle(rotationDegrees: 0, isActive: true)
}

struct NeedleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX * 0.65, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX * 0.35, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
