//
//  ContentView.swift
//  Kotel
//
//  Created by Idan Moshe on 22/02/2026.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    @State private var viewModel = CompassViewModel()
    #if os(iOS)
    @State private var selectedTab = 0
    #endif

    var body: some View {
        ZStack {
            BackgroundView()

            switch viewModel.authStatus {
            case .notDetermined:
                PermissionView {
                    viewModel.start()
                }
            case .denied, .restricted:
                DeniedPermissionView()
            case .authorizedWhenInUse, .authorizedAlways:
                #if os(iOS)
                TabView(selection: $selectedTab) {
                    NavigatorContent(viewModel: viewModel)
                        .tag(0)
                        .tabItem {
                            Label(String(localized: "Compass", bundle: .main, comment: "Tab label for compass view"), systemImage: "safari.fill")
                        }
                    
                    SettingsView()
                        .tag(1)
                        .tabItem {
                            Label(String(localized: "Settings", bundle: .main, comment: "Tab label for settings view"), systemImage: "gearshape.fill")
                        }
                }
                #else
                NavigatorContent(viewModel: viewModel)
                    .toolbar {
                        ToolbarItem(placement: .automatic) {
                            SettingsLink {
                                Label(String(localized: "Settings", bundle: .main, comment: "Toolbar button to open settings"), systemImage: "gearshape")
                            }
                        }
                    }
                #endif
            @unknown default:
                PermissionView {
                    viewModel.start()
                }
            }
        }
        .task {
            viewModel.start()
        }
        .preferredColorScheme(.dark)
    }
}

#Preview("ContentView") {
    ContentView()
}

struct BackgroundView: View {
    var body: some View {
        MeshGradient(
            width: 3, height: 3,
            points: [
                [0, 0], [0.5, 0], [1, 0],
                [0, 0.5], [0.5, 0.5], [1, 0.5],
                [0, 1], [0.5, 1], [1, 1]
            ],
            colors: [
                .black, Color(red: 0.05, green: 0.05, blue: 0.15), .black,
                Color(red: 0.02, green: 0.02, blue: 0.1), Color(red: 0.08, green: 0.06, blue: 0.18), Color(red: 0.02, green: 0.02, blue: 0.1),
                .black, Color(red: 0.04, green: 0.03, blue: 0.12), .black
            ]
        )
        .ignoresSafeArea()
    }
}

#Preview("BackgroundView") {
    BackgroundView()
}

struct NavigatorContent: View {
    @Bindable var viewModel: CompassViewModel
    let settings = AppSettings.shared

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "building.columns.fill")
                        .font(.caption)
                        .foregroundStyle(.yellow.opacity(0.8))
                    Text("Western Wall", bundle: .main, comment: "Title for the Western Wall")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.5))
                }

                Text(verbatim: "הכותל המערבי")
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                    .environment(\.layoutDirection, .rightToLeft)
            }
            .padding(.bottom, 40)

            ZStack {
                CompassView(
                    rotationDegrees: viewModel.rotationAngle,
                    isActive: viewModel.hasLocation
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
                    .offset(y: 160)
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
        .padding(.horizontal, 20)
    }
}

#Preview("NavigatorContent") {
    @Previewable @State var viewModel = CompassViewModel()
    NavigatorContent(viewModel: viewModel)
}

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

