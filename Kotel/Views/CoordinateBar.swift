//
//  CoordinateBar.swift
//  Kotel
//
//  Created by Idan Moshe on 22/02/2026.
//

import SwiftUI
import CoreLocation

struct CoordinateBar: View {
    let viewModel: CompassViewModel

    var body: some View {
        HStack {
            if let location = viewModel.locationService.location {
                Label(
                    String(format: "%.4f°, %.4f°", location.coordinate.latitude, location.coordinate.longitude),
                    systemImage: "mappin.circle"
                )
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.25))
            }

            Spacer()

            Label(
                String(format: "%.0f°", viewModel.compassHeading),
                systemImage: "safari"
            )
            .font(.caption2)
            .foregroundStyle(.white.opacity(0.25))
        }
    }
}

#Preview("CoordinateBar") {
    @Previewable @State var viewModel = CompassViewModel()
    CoordinateBar(viewModel: viewModel)
}
