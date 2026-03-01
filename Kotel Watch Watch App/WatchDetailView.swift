//
//  WatchDetailView.swift
//  Kotel Watch Watch App
//
//  Created by Claude Code on 01/03/2026.
//

import SwiftUI
import CoreLocation
import MapKit

/// Detailed information view for Apple Watch
struct WatchDetailView: View {
    @Bindable var viewModel: CompassViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Map view
            mapViewTab
                .tag(0)

            // Info view
            infoViewTab
                .tag(1)
        }
        .tabViewStyle(.verticalPage)
    }

    private var mapViewTab: some View {
        Group {
            if let userLocation = viewModel.locationService.location {
                Map {
                    // User location
                    Annotation("", coordinate: userLocation.coordinate) {
                        Circle()
                            .fill(.blue)
                            .frame(width: 10, height: 10)
                            .overlay(
                                Circle()
                                    .stroke(.white, lineWidth: 2)
                            )
                    }

                    // Western Wall
                    Annotation("הכותל", coordinate: CompassViewModel.westernWallCoordinate) {
                        Image(systemName: "building.columns.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.yellow)
                            .padding(4)
                            .background(.black.opacity(0.7))
                            .clipShape(Circle())
                    }
                }
                .mapStyle(.standard(elevation: .realistic))
                .allowsHitTesting(false)
                .overlay(alignment: .top) {
                    Text("Map View", bundle: .main, comment: "Map view title on watch")
                        .font(.caption2)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(.ultraThinMaterial, in: Capsule())
                        .padding(.top, 4)
                }
                .overlay(alignment: .bottom) {
                    if let distance = viewModel.distanceToWall {
                        Text(viewModel.formattedDistance(distance))
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.ultraThinMaterial, in: Capsule())
                            .padding(.bottom, 4)
                    }
                }
            } else {
                VStack(spacing: 8) {
                    ProgressView()
                    Text("Loading map…", bundle: .main, comment: "Loading map message on watch")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
        }
    }
    
    private var infoViewTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Information", bundle: .main, comment: "Information view title on watch")
                    .font(.headline)
                    .foregroundStyle(.white)
                
                if let location = viewModel.locationService.location {
                    infoRow(
                        label: String(localized: "Your Location", bundle: .main, comment: "Your location label on watch"),
                        value: "\(location.coordinate.latitude.formatted(.number.precision(.fractionLength(4)))), \(location.coordinate.longitude.formatted(.number.precision(.fractionLength(4))))"
                    )
                }
                
                if let distance = viewModel.distanceToWall {
                    infoRow(
                        label: String(localized: "Distance", bundle: .main, comment: "Distance label on watch"),
                        value: viewModel.formattedDistance(distance)
                    )
                }
                
                infoRow(
                    label: String(localized: "Bearing", bundle: .main, comment: "Bearing label on watch"),
                    value: "\(viewModel.bearingToWall.formatted(.number.precision(.fractionLength(1))))°"
                )
                
                if let heading = viewModel.locationService.heading {
                    let headingValue = viewModel.settings.useTrueNorth && heading.trueHeading >= 0 
                        ? heading.trueHeading 
                        : heading.magneticHeading
                    
                    infoRow(
                        label: String(localized: "Heading", bundle: .main, comment: "Heading label on watch"),
                        value: "\(headingValue.formatted(.number.precision(.fractionLength(1))))°"
                    )
                }
                
                infoRow(
                    label: String(localized: "Accuracy", bundle: .main, comment: "Accuracy label on watch"),
                    value: viewModel.isCalibrating 
                        ? String(localized: "Calibrating…", bundle: .main, comment: "Calibrating status on watch")
                        : String(localized: "Good", bundle: .main, comment: "Good accuracy status on watch")
                )
            }
            .padding()
        }
    }
    
    @ViewBuilder
    private func infoRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.6))
            
            Text(value)
                .font(.caption)
                .foregroundStyle(.white)
        }
    }
}

#Preview {
    @Previewable @State var viewModel = CompassViewModel()
    WatchDetailView(viewModel: viewModel)
}
