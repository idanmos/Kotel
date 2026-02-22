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
            if isActive {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.yellow.opacity(0.15), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(rotationDegrees))
            }

            VStack(spacing: 0) {
                NeedleShape()
                    .fill(
                        LinearGradient(
                            colors: isActive ? [.yellow, .orange] : [.gray.opacity(0.5), .gray.opacity(0.3)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 20, height: 90)

                NeedleShape()
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.15), .white.opacity(0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 20, height: 90)
                    .rotationEffect(.degrees(180))
            }
            .rotationEffect(.degrees(rotationDegrees))

            Circle()
                .fill(
                    RadialGradient(
                        colors: isActive ? [.yellow.opacity(0.8), .orange.opacity(0.6)] : [.gray.opacity(0.5), .gray.opacity(0.3)],
                        center: .center,
                        startRadius: 0,
                        endRadius: 10
                    )
                )
                .frame(width: 16, height: 16)

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
