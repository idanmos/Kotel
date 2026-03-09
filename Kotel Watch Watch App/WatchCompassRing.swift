//
//  WatchCompassRing.swift
//  Kotel Watch Watch App
//
//  Created by Idan Moshe on 24/02/2026.
//

import SwiftUI

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
