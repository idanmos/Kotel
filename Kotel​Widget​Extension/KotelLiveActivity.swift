//
//  KotelLiveActivity.swift
//  KotelWidgetExtension
//
//  Created by Idan Moshe on 24/02/2026.
//

import ActivityKit
import SwiftUI
import WidgetKit

/// Live Activity for Kotel compass tracking
struct KotelLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: KotelActivityAttributes.self) { context in
            // Lock Screen presentation
            LockScreenLiveActivityView(context: context)
        } dynamicIsland: { context in
            // Dynamic Island presentations
            DynamicIsland {
                // Expanded presentation
                DynamicIslandExpandedRegion(.leading) {
                    ExpandedLeadingView(context: context)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    ExpandedTrailingView(context: context)
                }
                
                DynamicIslandExpandedRegion(.center) {
                    ExpandedCenterView(context: context)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    ExpandedBottomView(context: context)
                }
            } compactLeading: {
                // Compact leading (left side of Dynamic Island)
                CompactLeadingView(context: context)
            } compactTrailing: {
                // Compact trailing (right side of Dynamic Island)
                CompactTrailingView(context: context)
            } minimal: {
                // Minimal presentation (when multiple activities are running)
                MinimalView(context: context)
            }
        }
    }
}

// MARK: - Lock Screen View

/// Lock Screen Live Activity presentation
struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<KotelActivityAttributes>

    var rotationAngle: Double {
        context.state.bearingToWall - context.state.compassHeading
    }

    var body: some View {
        HStack(spacing: 16) {
            // Enhanced compass indicator with smooth animation
            ZStack {
                // Outer glow ring
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [.yellow.opacity(0.4), .yellow.opacity(0.1)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 54, height: 54)
                    .blur(radius: 1)

                // Main ring
                Circle()
                    .stroke(Color.yellow.opacity(0.3), lineWidth: 2)
                    .frame(width: 50, height: 50)

                // Cardinal direction indicator (North)
                Circle()
                    .fill(Color.yellow.opacity(0.6))
                    .frame(width: 3, height: 3)
                    .offset(y: -22)

                if context.state.hasLocation && !context.state.isCalibrating {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.yellow)
                        .rotationEffect(.degrees(rotationAngle))
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: rotationAngle)
                        .shadow(color: .yellow.opacity(0.5), radius: 4)
                } else if context.state.isCalibrating {
                    Image(systemName: "gyroscope")
                        .font(.title3)
                        .foregroundStyle(.yellow.opacity(0.6))
                        .symbolEffect(.variableColor.iterative, options: .repeating)
                } else {
                    Image(systemName: "location.slash")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "building.columns.fill")
                        .font(.caption)
                        .foregroundStyle(.yellow)
                    Text("Western Wall", bundle: .main, comment: "Title for the Western Wall")
                        .font(.subheadline.bold())
                }

                if context.state.hasLocation {
                    HStack(spacing: 6) {
                        Text(context.state.formattedDistance)
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                            .contentTransition(.numericText())

                        Text("• \(Int(context.state.bearingToWall))°")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .contentTransition(.numericText())
                    }
                } else {
                    Text("Acquiring location…", bundle: .main, comment: "Message shown while getting GPS location")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }

                Text("Heading: \(Int(context.state.compassHeading))°", bundle: .main, comment: "Current compass heading display")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .contentTransition(.numericText())
            }

            Spacer()
        }
        .padding()
        .activityBackgroundTint(.black.opacity(0.3))
        .activitySystemActionForegroundColor(.white)
    }
}

// MARK: - Dynamic Island Compact Views

/// Compact leading view (left icon in Dynamic Island)
struct CompactLeadingView: View {
    let context: ActivityViewContext<KotelActivityAttributes>
    
    var body: some View {
        Image(systemName: "building.columns.fill")
            .foregroundStyle(.yellow)
    }
}

/// Compact trailing view (right content in Dynamic Island)
struct CompactTrailingView: View {
    let context: ActivityViewContext<KotelActivityAttributes>

    var rotationAngle: Double {
        context.state.bearingToWall - context.state.compassHeading
    }

    var body: some View {
        if context.state.hasLocation && !context.state.isCalibrating {
            Image(systemName: "arrow.up.circle.fill")
                .foregroundStyle(.yellow)
                .rotationEffect(.degrees(rotationAngle))
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: rotationAngle)
        } else if context.state.isCalibrating {
            Image(systemName: "gyroscope")
                .foregroundStyle(.yellow.opacity(0.6))
                .symbolEffect(.variableColor.iterative, options: .repeating)
        } else {
            Image(systemName: "location.slash")
                .foregroundStyle(.secondary)
        }
    }
}

/// Minimal view (when multiple activities)
struct MinimalView: View {
    let context: ActivityViewContext<KotelActivityAttributes>

    var rotationAngle: Double {
        context.state.bearingToWall - context.state.compassHeading
    }

    var body: some View {
        if context.state.hasLocation && !context.state.isCalibrating {
            Image(systemName: "arrow.up.circle.fill")
                .foregroundStyle(.yellow)
                .rotationEffect(.degrees(rotationAngle))
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: rotationAngle)
        } else {
            Image(systemName: "building.columns.fill")
                .foregroundStyle(.yellow)
        }
    }
}

// MARK: - Dynamic Island Expanded Views

/// Expanded leading region
struct ExpandedLeadingView: View {
    let context: ActivityViewContext<KotelActivityAttributes>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: "building.columns.fill")
                    .font(.caption)
                    .foregroundStyle(.yellow)
                Text("Kotel", bundle: .main, comment: "Short name for the Western Wall")
                    .font(.caption.bold())
            }
            
            if context.state.hasLocation {
                Text(context.state.formattedDistance)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } else {
                Text("No location", bundle: .main, comment: "Message when location data is unavailable")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
    }
}

/// Expanded trailing region
struct ExpandedTrailingView: View {
    let context: ActivityViewContext<KotelActivityAttributes>

    var rotationAngle: Double {
        context.state.bearingToWall - context.state.compassHeading
    }

    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [.yellow.opacity(0.4), .yellow.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 3
                )
                .frame(width: 54, height: 54)
                .blur(radius: 1)

            Circle()
                .stroke(Color.yellow.opacity(0.3), lineWidth: 2)
                .frame(width: 50, height: 50)

            // North indicator
            Circle()
                .fill(Color.yellow.opacity(0.6))
                .frame(width: 3, height: 3)
                .offset(y: -22)

            if context.state.hasLocation && !context.state.isCalibrating {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.yellow)
                    .rotationEffect(.degrees(rotationAngle))
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: rotationAngle)
                    .shadow(color: .yellow.opacity(0.5), radius: 4)
            } else if context.state.isCalibrating {
                Image(systemName: "gyroscope")
                    .font(.title3)
                    .foregroundStyle(.yellow.opacity(0.6))
                    .symbolEffect(.variableColor.iterative, options: .repeating)
            } else {
                Image(systemName: "location.slash")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

/// Expanded center region
struct ExpandedCenterView: View {
    let context: ActivityViewContext<KotelActivityAttributes>
    
    var body: some View {
        Text(verbatim: "הכותל המערבי")
            .font(.title3.bold())
            .foregroundStyle(.white)
            .environment(\.layoutDirection, .rightToLeft)
    }
}

/// Expanded bottom region
struct ExpandedBottomView: View {
    let context: ActivityViewContext<KotelActivityAttributes>
    
    var body: some View {
        HStack {
            Label("\(Int(context.state.compassHeading))°", systemImage: "safari")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            if context.state.isCalibrating {
                Label {
                    Text("Calibrating…", bundle: .main, comment: "Message shown while calibrating compass")
                } icon: {
                    Image(systemName: "gyroscope")
                }
                .font(.caption)
                .foregroundStyle(.yellow.opacity(0.7))
            } else if context.state.hasLocation {
                Label {
                    Text("Active", bundle: .main, comment: "Status label indicating compass is active")
                } icon: {
                    Image(systemName: "checkmark.circle.fill")
                }
                .font(.caption)
                .foregroundStyle(.green)
            } else {
                Label {
                    Text("Searching…", bundle: .main, comment: "Status label while searching for location")
                } icon: {
                    Image(systemName: "location.magnifyingglass")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 12)
    }
}
