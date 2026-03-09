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
    var size: CGFloat = 300

    var body: some View {
        let scale = size / 300

        ZStack {
            CompassRing(scale: scale)

            DirectionNeedle(rotationDegrees: rotationDegrees, isActive: isActive, scale: scale)
        }
        .frame(width: size, height: size)
        .environment(\.layoutDirection, .leftToRight)
    }
}

#Preview("CompassView") {
    CompassView(rotationDegrees: 0, isActive: true)
}
