//
//  DistanceCard.swift
//  Kotel
//
//  Created by Idan Moshe on 22/02/2026.
//

import SwiftUI
import CoreLocation

struct DistanceCard: View {
    let distance: CLLocationDistance
    let viewModel: CompassViewModel

    var body: some View {
        VStack(spacing: 8) {
            Text("Distance to Kotel", bundle: .main, comment: "Label showing distance to the Western Wall")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.4))
                .textCase(.uppercase)
                .tracking(1.5)

            Text(viewModel.formattedDistance(distance))
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .contentTransition(.numericText())
                .animation(.snappy, value: viewModel.formattedDistance(distance))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(.white.opacity(0.04))
        .clipShape(.rect(cornerRadius: 16))
    }
}

#Preview("DistanceCard") {
    @Previewable @State var viewModel = CompassViewModel()
    DistanceCard(distance: 5000, viewModel: viewModel)
}
