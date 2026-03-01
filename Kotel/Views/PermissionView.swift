//
//  PermissionView.swift
//  Kotel
//
//  Created by Idan Moshe on 22/02/2026.
//

import SwiftUI

struct PermissionView: View {
    let onRequestPermission: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "location.north.fill")
                .font(.system(size: 64))
                .foregroundStyle(.yellow)
                .symbolEffect(.pulse.byLayer, options: .repeating)

            VStack(spacing: 12) {
                Text("Find the Western Wall", bundle: .main, comment: "Permission screen title")
                    .font(.title.bold())
                    .foregroundStyle(.white)

                Text("Allow location access so we can\npoint you toward the Kotel in Jerusalem", bundle: .main, comment: "Permission screen description")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            Button {
                onRequestPermission()
            } label: {
                Label {
                    Text("Enable Location", bundle: .main, comment: "Button to enable location services")
                } icon: {
                    Image(systemName: "location.fill")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .tint(.yellow)
            .foregroundStyle(.black)
            .padding(.horizontal, 40)

            Spacer()
            Spacer()
        }
    }
}

#Preview("PermissionView") {
    PermissionView {
        print("onRequestPermission called")
    }
}

struct DeniedPermissionView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "location.slash.fill")
                .font(.system(size: 56))
                .foregroundStyle(.orange)

            VStack(spacing: 12) {
                Text("Location Access Needed", bundle: .main, comment: "Denied permission screen title")
                    .font(.title2.bold())
                    .foregroundStyle(.white)

                Text("Open Settings and enable location\naccess to use the Western Wall compass", bundle: .main, comment: "Denied permission screen description")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            Button {
                openLocationSettings()
            } label: {
                Label {
                    Text("Open Settings", bundle: .main, comment: "Button to open Settings app")
                } icon: {
                    Image(systemName: "gear")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .foregroundStyle(.black)
            .padding(.horizontal, 40)

            Spacer()
            Spacer()
        }
    }

    private func openLocationSettings() {
        #if os(iOS)
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
        #elseif os(macOS)
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_LocationServices") {
            NSWorkspace.shared.open(url)
        }
        #endif
    }
}

#Preview("DeniedPermissionView") {
    DeniedPermissionView()
}
