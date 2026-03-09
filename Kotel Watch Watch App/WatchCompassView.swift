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
        GeometryReader { geometry in
            let scale = min(geometry.size.width, geometry.size.height) / 140

            ZStack {
                WatchCompassRing()
                WatchDirectionNeedle(rotationDegrees: rotationDegrees, isActive: isActive)
            }
            .scaleEffect(scale)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    WatchCompassView(rotationDegrees: 0, isActive: true)
}
