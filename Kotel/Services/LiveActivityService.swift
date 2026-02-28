//
//  LiveActivityService.swift
//  Kotel
//
//  Created by Idan Moshe on 24/02/2026.
//

#if canImport(ActivityKit)
import ActivityKit
import Foundation

/// Service to manage Live Activity for the Kotel app
@available(iOS 16.1, *)
@Observable
class LiveActivityService {
    private(set) var currentActivity: Activity<KotelActivityAttributes>?
    
    /// Starts a new Live Activity with the given state
    /// - Parameter state: The initial content state for the activity
    func startActivity(state: KotelActivityAttributes.ContentState) {
        print("🎯 LiveActivityService.startActivity() called")
        print("   → Checking if Live Activities are enabled...")

        let authInfo = ActivityAuthorizationInfo()
        print("   → areActivitiesEnabled: \(authInfo.areActivitiesEnabled)")

        guard authInfo.areActivitiesEnabled else {
            print("❌ Live Activities are NOT enabled in Settings!")
            print("   → Go to: Settings → Face ID & Passcode → Live Activities")
            return
        }

        print("✅ Live Activities are enabled!")

        // End existing activity if any
        if currentActivity != nil {
            print("   → Ending existing activity first...")
            endActivity()
        }

        let attributes = KotelActivityAttributes()
        print("   → Created attributes: lat=\(attributes.wallLatitude), lon=\(attributes.wallLongitude)")
        print("   → State: bearing=\(state.bearingToWall)°, heading=\(state.compassHeading)°, distance=\(state.distanceInMeters)m")

        do {
            print("   → Requesting Live Activity...")
            let activity = try Activity<KotelActivityAttributes>.request(
                attributes: attributes,
                content: .init(state: state, staleDate: nil),
                pushType: nil
            )

            currentActivity = activity
            print("🎉 Live Activity started successfully!")
            print("   → Activity ID: \(activity.id)")
            print("   → Activity state: \(activity.activityState)")
        } catch {
            print("❌ Failed to start Live Activity!")
            print("   → Error: \(error)")
            print("   → Error details: \(error.localizedDescription)")
        }
    }
    
    /// Updates the current Live Activity with new state
    /// - Parameter state: The updated content state
    func updateActivity(state: KotelActivityAttributes.ContentState) async {
        guard let activity = currentActivity else {
            return
        }
        
        let content = ActivityContent(state: state, staleDate: nil)
        
        await activity.update(content)
    }
    
    /// Ends the current Live Activity
    /// - Parameter dismissalPolicy: When to dismiss the activity (defaults to immediate)
    func endActivity(dismissalPolicy: ActivityUIDismissalPolicy = .immediate) {
        guard let activity = currentActivity else {
            return
        }
        
        Task {
            await activity.end(nil, dismissalPolicy: dismissalPolicy)
            currentActivity = nil
            print("Live Activity ended")
        }
    }
    
    /// Creates a content state from the current compass data
    /// - Parameters:
    ///   - bearingToWall: Bearing to the Western Wall in degrees
    ///   - compassHeading: Current compass heading in degrees
    ///   - distanceInMeters: Distance to the Western Wall in meters
    ///   - hasLocation: Whether location is available
    ///   - isCalibrating: Whether the compass is calibrating
    ///   - formattedDistance: Formatted distance string
    /// - Returns: A content state for the Live Activity
    static func createContentState(
        bearingToWall: Double,
        compassHeading: Double,
        distanceInMeters: Double,
        hasLocation: Bool,
        isCalibrating: Bool,
        formattedDistance: String
    ) -> KotelActivityAttributes.ContentState {
        KotelActivityAttributes.ContentState(
            bearingToWall: bearingToWall,
            compassHeading: compassHeading,
            distanceInMeters: distanceInMeters,
            hasLocation: hasLocation,
            isCalibrating: isCalibrating,
            formattedDistance: formattedDistance,
            lastUpdate: Date()
        )
    }
}
#endif
