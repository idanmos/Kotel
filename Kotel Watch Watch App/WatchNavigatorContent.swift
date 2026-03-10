//
//  WatchNavigatorContent.swift
//  Kotel Watch Watch App
//
//  Created by Idan Moshe on 24/02/2026.
//

import SwiftUI

struct WatchNavigatorContent: View {
    @Bindable var viewModel: CompassViewModel

    var body: some View {
        TabView {
            compassTab

            WatchSettingsView(settings: viewModel.settings)
        }
        .tabViewStyle(.verticalPage)
    }

    private var compassTab: some View {
        GeometryReader { geometry in
            let titleHeight: CGFloat = 18
            let bottomHeight: CGFloat = {
                if !viewModel.hasLocation {
                    return 20
                }

                if viewModel.settings.showDistance, viewModel.distanceToWall != nil {
                    return 34
                }

                return 0
            }()
            let spacing: CGFloat = 6
            let compassSide = max(
                0,
                min(
                    geometry.size.width,
                    geometry.size.height - titleHeight - bottomHeight - (spacing * 2)
                )
            )

            VStack(spacing: spacing) {
                Text("Jerusalem", bundle: .main, comment: "City label shown above compass on watch")
                    .font(.caption.bold())
                    .foregroundStyle(.white.opacity(0.85))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                WatchCompassView(
                    rotationDegrees: viewModel.rotationAngle,
                    isActive: viewModel.hasLocation
                )
                .frame(width: compassSide, height: compassSide)
                .animation(.smooth(duration: 0.3), value: viewModel.rotationAngle)

                if let distance = viewModel.distanceToWall, viewModel.settings.showDistance {
                    VStack(spacing: 2) {
                        Text("Distance", bundle: .main, comment: "Label showing distance to the Western Wall on watch")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.45))

                        Text(viewModel.formattedDistance(distance))
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.white)
                            .contentTransition(.numericText())
                    }
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                } else if !viewModel.hasLocation {
                    HStack(spacing: 4) {
                        ProgressView()
                            .tint(.white.opacity(0.5))
                        Text("Acquiring…", bundle: .main, comment: "Message shown while getting GPS location on watch")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.45))
                    }
                    .lineLimit(1)
                }
            }
            .padding(.horizontal, 6)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview("WatchNavigatorContent") {
    @Previewable @State var viewModel = CompassViewModel()
    WatchNavigatorContent(viewModel: viewModel)
}
