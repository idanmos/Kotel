//
//  NavigatorContent.swift
//  Kotel
//
//  Created by Idan Moshe on 22/02/2026.
//

import SwiftUI
import CoreLocation

struct NavigatorContent: View {
    @Bindable var viewModel: CompassViewModel
    let settings = AppSettings.shared
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var isPadLayout: Bool {
        horizontalSizeClass == .regular
    }

    var body: some View {
        GeometryReader { proxy in
            let maxHorizontalPadding: CGFloat = 20
            let availableWidth = max(0, proxy.size.width - (maxHorizontalPadding * 2))
            let contentMaxWidth = isPadLayout ? min(availableWidth, 820) : availableWidth
            let compassSize = min(
                max(proxy.size.width * (isPadLayout ? 0.48 : 0.62), 300),
                isPadLayout ? 520 : 380
            )

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "building.columns.fill")
                            .font(.caption)
                            .foregroundStyle(.yellow.opacity(0.8))
                        Text("Western Wall", bundle: .main, comment: "Title for the Western Wall")
                            .font(isPadLayout ? .title3 : .subheadline)
                            .foregroundStyle(.white.opacity(0.5))
                    }

                    Text(verbatim: "הכותל המערבי")
                        .font(.system(size: isPadLayout ? 36 : 28, weight: .bold, design: .serif))
                        .foregroundStyle(.white)
                        .environment(\.layoutDirection, .rightToLeft)
                }
                .padding(.bottom, isPadLayout ? 56 : 40)

                ZStack {
                    CompassView(
                        rotationDegrees: viewModel.rotationAngle,
                        isActive: viewModel.hasLocation,
                        size: compassSize
                    )
                    .animation(.smooth(duration: 0.3), value: viewModel.rotationAngle)

                    if viewModel.isCalibrating {
                        VStack(spacing: 8) {
                            Image(systemName: "gyroscope")
                                .font(.title2)
                                .symbolEffect(.variableColor.iterative, options: .repeating)
                            Text("Calibrating…", bundle: .main, comment: "Message shown while calibrating compass")
                                .font(.caption)
                        }
                        .foregroundStyle(.white.opacity(0.5))
                        .offset(y: compassSize * 0.52)
                    }
                }

                Spacer()

                if settings.showDistance, let distance = viewModel.distanceToWall {
                    DistanceCard(distance: distance, viewModel: viewModel)
                        .padding(.bottom, 16)
                }

                if !viewModel.hasLocation {
                    HStack(spacing: 8) {
                        ProgressView()
                            .tint(.white.opacity(0.5))
                        Text("Acquiring location…", bundle: .main, comment: "Message shown while getting GPS location")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.4))
                    }
                    .padding(.bottom, 32)
                }

                if settings.showCoordinates {
                    CoordinateBar(viewModel: viewModel)
                        .padding(.bottom, 8)
                }
            }
            .frame(maxWidth: contentMaxWidth)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, maxHorizontalPadding)
        }
    }
}

#Preview("NavigatorContent") {
    @Previewable @State var viewModel = CompassViewModel()
    NavigatorContent(viewModel: viewModel)
}
