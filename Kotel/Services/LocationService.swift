//
//  LocationService.swift
//  Kotel
//
//  Created by Idan Moshe on 22/02/2026.
//

import CoreLocation
import SwiftUI
#if os(iOS)
import BackgroundTasks
#endif

/// LocationService manages location and heading updates with comprehensive background support.
/// Leverages three background modes: location updates, background fetch, and background processing.
@Observable
class LocationService: NSObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    var location: CLLocation?
    var heading: CLHeading?
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var locationError: String?
    
    #if os(iOS)
    private static let backgroundTaskIdentifier = "com.idanmoshe.Kotel.locationUpdate"
    private var isMonitoringSignificantChanges = false
    #endif

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.headingFilter = 1
        
        #if os(iOS)
        // Optimize for battery life while maintaining accuracy
        manager.activityType = .other
        manager.pausesLocationUpdatesAutomatically = false
        
        // Register background task
        registerBackgroundTask()
        #endif
    }

    func requestPermission() {
        manager.requestAlwaysAuthorization()
    }

    /// Starts standard location and heading updates (foreground)
    func startUpdates() {
        manager.startUpdatingLocation()
        manager.startUpdatingHeading()
    }

    /// Stops all location and heading updates
    func stopUpdates() {
        manager.stopUpdatingLocation()
        manager.stopUpdatingHeading()
        
        #if os(iOS)
        if isMonitoringSignificantChanges {
            manager.stopMonitoringSignificantLocationChanges()
            isMonitoringSignificantChanges = false
        }
        #endif
    }
    
    #if os(iOS)
    /// Starts energy-efficient background location monitoring using significant location changes
    func startBackgroundMonitoring() {
        guard authorizationStatus == .authorizedAlways else {
            print("Background monitoring requires Always authorization")
            return
        }
        
        if !isMonitoringSignificantChanges {
            manager.startMonitoringSignificantLocationChanges()
            isMonitoringSignificantChanges = true
            print("Started monitoring significant location changes for background updates")
        }
        
        // Schedule background refresh task
        scheduleBackgroundLocationUpdate()
    }
    
    /// Stops background location monitoring
    func stopBackgroundMonitoring() {
        if isMonitoringSignificantChanges {
            manager.stopMonitoringSignificantLocationChanges()
            isMonitoringSignificantChanges = false
        }
    }
    
    /// Registers the background task handler for periodic location updates
    private func registerBackgroundTask() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Self.backgroundTaskIdentifier,
            using: nil
        ) { task in
            self.handleBackgroundLocationUpdate(task: task as! BGProcessingTask)
        }
    }
    
    /// Schedules a background processing task for location updates
    private func scheduleBackgroundLocationUpdate() {
        let request = BGProcessingTaskRequest(identifier: Self.backgroundTaskIdentifier)
        request.requiresNetworkConnectivity = false
        request.requiresExternalPower = false
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutes
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("Scheduled background location update task")
        } catch {
            print("Failed to schedule background task: \(error)")
        }
    }
    
    /// Handles background location update task
    private func handleBackgroundLocationUpdate(task: BGProcessingTask) {
        // Schedule the next update
        scheduleBackgroundLocationUpdate()
        
        // Set expiration handler
        task.expirationHandler = {
            print("Background task expired")
            task.setTaskCompleted(success: false)
        }
        
        // Request a fresh location update
        manager.requestLocation()
        
        // Give it a moment to complete, then mark task as done
        Task {
            try? await Task.sleep(for: .seconds(5))
            task.setTaskCompleted(success: true)
        }
    }
    #endif

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            self.location = locations.last
            print("Location updated: \(locations.last?.coordinate.latitude ?? 0), \(locations.last?.coordinate.longitude ?? 0)")
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        Task { @MainActor in
            self.heading = newHeading
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        #if os(iOS)
        // Only enable background updates after Always authorization is granted
        // This MUST be set synchronously before returning from the delegate callback
        if manager.authorizationStatus == .authorizedAlways {
            manager.allowsBackgroundLocationUpdates = true
            manager.showsBackgroundLocationIndicator = true
        } else {
            manager.allowsBackgroundLocationUpdates = false
        }
        #endif
        
        Task { @MainActor in
            self.authorizationStatus = manager.authorizationStatus
            
            if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
                self.startUpdates()
                
                #if os(iOS)
                // Start background monitoring if we have Always authorization
                if manager.authorizationStatus == .authorizedAlways {
                    self.startBackgroundMonitoring()
                }
                #endif
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.locationError = error.localizedDescription
            print("Location error: \(error.localizedDescription)")
        }
    }
}
