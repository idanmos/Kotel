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
            if isActive {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.yellow.opacity(0.15), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 40
                        )
                    )
                    .frame(width: 80, height: 80)
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
                    .frame(width: 12, height: 45)

                NeedleShape()
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.15), .white.opacity(0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 12, height: 45)
                    .rotationEffect(.degrees(180))
            }
            .rotationEffect(.degrees(rotationDegrees))

            Circle()
                .fill(
                    RadialGradient(
                        colors: isActive ? [.yellow.opacity(0.8), .orange.opacity(0.6)] : [.gray.opacity(0.5), .gray.opacity(0.3)],
                        center: .center,
                        startRadius: 0,
                        endRadius: 8
                    )
                )
                .frame(width: 12, height: 12)

            Circle()
                .fill(.white.opacity(0.9))
                .frame(width: 4, height: 4)
        }
    }
}

#Preview {
    WatchDirectionNeedle(rotationDegrees: 0, isActive: true)
}
