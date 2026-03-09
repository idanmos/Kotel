//
//  WatchPermissionView.swift
//  Kotel Watch Watch App
//
//  Created by Idan Moshe on 24/02/2026.
//

import SwiftUI

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
