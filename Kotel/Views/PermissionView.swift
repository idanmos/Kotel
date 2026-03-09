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
