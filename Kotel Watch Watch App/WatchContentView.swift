//
//  ContentView.swift
//  Kotel Watch Watch App
//
//  Created by Idan Moshe on 24/02/2026.
//

import SwiftUI
import CoreLocation

struct WatchContentView: View {
    @State private var viewModel = CompassViewModel()

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            switch viewModel.authStatus {
            case .notDetermined:
                WatchPermissionView {
                    viewModel.start()
                }
            case .denied, .restricted:
                WatchDeniedPermissionView()
            case .authorizedWhenInUse, .authorizedAlways:
                WatchNavigatorContent(viewModel: viewModel)
            @unknown default:
                WatchPermissionView {
                    viewModel.start()
                }
            }
        }
    }
}

#Preview {
    WatchContentView()
}

struct WatchNavigatorContent: View {
    @Bindable var viewModel: CompassViewModel

    var body: some View {
        VStack(spacing: 8) {
            Text(verbatim: "הכותל")
                .font(.system(size: 18, weight: .bold, design: .serif))
                .foregroundStyle(.white)
                .environment(\.layoutDirection, .rightToLeft)

            Spacer()

            WatchCompassView(
                rotationDegrees: viewModel.rotationAngle,
                isActive: viewModel.hasLocation
            )
            .animation(.smooth(duration: 0.3), value: viewModel.rotationAngle)

            if viewModel.isCalibrating {
                Image(systemName: "gyroscope")
                    .font(.caption2)
                    .symbolEffect(.variableColor.iterative, options: .repeating)
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()

            if let distance = viewModel.distanceToWall {
                Text(viewModel.formattedDistance(distance))
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
                    .animation(.snappy, value: viewModel.formattedDistance(distance))
            }

            if !viewModel.hasLocation {
                HStack(spacing: 4) {
                    ProgressView()
                        .tint(.white.opacity(0.5))
                    Text("Acquiring…", bundle: .main, comment: "Message shown while getting GPS location on watch")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.4))
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview("WatchNavigatorContent") {
    @Previewable @State var viewModel = CompassViewModel()
    WatchNavigatorContent(viewModel: viewModel)
}

struct WatchPermissionView: View {
    let onRequestPermission: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "location.circle.fill")
                .font(.system(size: 40))
                .foregroundStyle(.blue)

            Text("Location Needed", bundle: .main, comment: "Watch permission view title")
                .font(.headline)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text("To point toward the Kotel", bundle: .main, comment: "Watch permission view description")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)

            Button {
                onRequestPermission()
            } label: {
                Text("Allow Location", bundle: .main, comment: "Watch button to allow location")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview("WatchPermissionView") {
    WatchPermissionView {}
}

struct WatchDeniedPermissionView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "location.slash.circle.fill")
                .font(.system(size: 40))
                .foregroundStyle(.red)

            Text("Location Denied", bundle: .main, comment: "Watch denied permission title")
                .font(.headline)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text("Enable in Settings", bundle: .main, comment: "Watch denied permission description")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview("WatchDeniedPermissionView") {
    WatchDeniedPermissionView()
}
