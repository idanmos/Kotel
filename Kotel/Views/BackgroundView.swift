//
//  BackgroundView.swift
//  Kotel
//
//  Created by Idan Moshe on 22/02/2026.
//

import SwiftUI

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
