//
//  ContentView.swift
//  Kotel Watch Watch App
//
//  Created by Idan Moshe on 24/02/2026.
//

import SwiftUI

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
                NavigationStack {
                    WatchNavigatorContent(viewModel: viewModel)
                        .navigationBarTitleDisplayMode(.inline)
                }
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

