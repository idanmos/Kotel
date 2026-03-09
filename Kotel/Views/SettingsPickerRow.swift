//
//  SettingsPickerRow.swift
//  Kotel
//
//  Created by Claude Code on 01/03/2026.
//

import SwiftUI

/// Settings row with a picker
struct SettingsPickerRow: View {
    let icon: String
    let title: String
    @Binding var selection: String
    let options: [(String, String)]

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(.yellow.opacity(0.8))
                    .frame(width: 32, height: 32)

                Text(title)
                    .font(.body)
                    .foregroundStyle(.white)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 8)
            .background(Color.white.opacity(0.02))

            Picker("", selection: $selection) {
                ForEach(options, id: \.0) { value, label in
                    Text(label).tag(value)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.bottom, 14)
            .background(Color.white.opacity(0.02))
        }
    }
}

#Preview("SettingsPickerRow") {
    SettingsPickerRow(
        icon: "arrow.left.and.right",
        title: "Distance Unit",
        selection: .constant("auto"),
        options: [("auto", "Auto"), ("metric", "Metric"), ("imperial", "Imperial")]
    )
}
