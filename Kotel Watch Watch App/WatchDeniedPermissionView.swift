//
//  WatchDeniedPermissionView.swift
//  Kotel Watch Watch App
//
//  Created by Idan Moshe on 24/02/2026.
//

import SwiftUI

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
