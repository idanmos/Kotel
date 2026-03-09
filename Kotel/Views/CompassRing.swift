//
//  CompassRing.swift
//  Kotel
//
//  Created by Idan Moshe on 22/02/2026.
//

import SwiftUI

struct CompassRing: View {
    var scale: CGFloat = 1

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
        .scaleEffect(scale)
    }
}

#Preview("CompassRing") {
    CompassRing()
}
