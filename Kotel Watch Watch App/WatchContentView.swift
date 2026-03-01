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
    @State private var showSettings = false
    @State private var showDetails = false

    /// Cardinal direction string for a bearing in degrees
    private func cardinalDirection(for bearing: Double) -> String {
        let normalized = bearing.truncatingRemainder(dividingBy: 360)
        let positive = normalized < 0 ? normalized + 360 : normalized
        let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        let index = Int((positive + 22.5) / 45.0) % 8
        return directions[index]
    }

    var body: some View {
        GeometryReader { geometry in
            let compassSize = min(geometry.size.width, geometry.size.height) * 0.65
            let scaleFactor = compassSize / 140.0

            ZStack {
                // Main content
                VStack(spacing: 2) {
                    Text(verbatim: "הכותל")
                        .font(.system(size: 14, weight: .bold, design: .serif))
                        .foregroundStyle(.white.opacity(0.8))
                        .environment(\.layoutDirection, .rightToLeft)
                        .padding(.top, 8)

                    Spacer(minLength: 0)

                    Button {
                        showDetails = true
                    } label: {
                        WatchCompassView(
                            rotationDegrees: viewModel.rotationAngle,
                            isActive: viewModel.hasLocation
                        )
                        .scaleEffect(scaleFactor)
                        .frame(width: compassSize, height: compassSize)
                    }
                    .buttonStyle(.plain)
                    .animation(.smooth(duration: 0.3), value: viewModel.rotationAngle)

                    if viewModel.isCalibrating {
                        Image(systemName: "gyroscope")
                            .font(.caption2)
                            .symbolEffect(.variableColor.iterative, options: .repeating)
                            .foregroundStyle(.white.opacity(0.5))
                    }

                    Spacer(minLength: 0)

                    // Distance + bearing
                    VStack(spacing: 2) {
                        if viewModel.settings.showDistance, let distance = viewModel.distanceToWall {
                            Text(viewModel.formattedDistance(distance))
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .contentTransition(.numericText())
                                .animation(.snappy, value: viewModel.formattedDistance(distance))
                                .minimumScaleFactor(0.8)
                        }

                        if viewModel.hasLocation {
                            let bearing = viewModel.bearingToWall
                            Text("\(Int(bearing))° \(cardinalDirection(for: bearing))")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(.white.opacity(0.5))
                        }
                    }
                    .padding(.bottom, 4)

                    if !viewModel.hasLocation {
                        HStack(spacing: 4) {
                            ProgressView()
                                .tint(.white.opacity(0.5))
                            Text("Acquiring…", bundle: .main, comment: "Message shown while getting GPS location on watch")
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.4))
                        }
                        .padding(.bottom, 4)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            // Settings overlay button
            .overlay(alignment: .topTrailing) {
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.white.opacity(0.5))
                        .padding(8)
                }
                .buttonStyle(.plain)
            }
        }
        .sheet(isPresented: $showSettings) {
            WatchSettingsView(settings: viewModel.settings)
        }
        .fullScreenCover(isPresented: $showDetails) {
            WatchDetailView(viewModel: viewModel)
        }
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
