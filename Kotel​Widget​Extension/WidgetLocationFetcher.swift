//
//  WidgetLocationFetcher.swift
//  KotelWidgetExtension
//
//  Created by Idan Moshe on 28/02/2026.
//

import CoreLocation
import Combine

/// Fetches location for the widget timeline provider.
///
/// Approach:
/// 1. Try the cached `CLLocationManager.location` first (no delegate needed).
/// 2. If no cache, fall back to `requestLocation()` bridged via Combine.
///
/// References:
/// - https://developer.apple.com/documentation/widgetkit/accessing-location-information-in-widgets
/// - https://blog.thomasdurand.fr/story/2023-12-10-location-sensitive-widget/
final class WidgetLocationFetcher: NSObject, CLLocationManagerDelegate {
    private let manager: CLLocationManager
    private let subject = PassthroughSubject<Result<CLLocation, Error>, Never>()

    override init() {
        manager = CLLocationManager()
        super.init()
        manager.delegate = self
    }

    deinit {
        print("[Widget] WidgetLocationFetcher DEALLOCATED")
    }

    /// Returns `true` when the widget extension is allowed to receive location.
    var isAuthorizedForWidgetUpdates: Bool {
        manager.isAuthorizedForWidgetUpdates
    }

    /// Attempts to get a location, trying the cache first.
    /// - Parameter maxAge: Maximum age of a cached location in seconds.
    /// - Returns: A location, or `nil` if unavailable.
    func fetchLocation(maxCacheAge: TimeInterval = 600) async -> CLLocation? {
        let authStatus = manager.authorizationStatus
        print("[Widget] fetchLocation: authStatus=\(authStatus.rawValue), isAuthorizedForWidgetUpdates=\(manager.isAuthorizedForWidgetUpdates)")

        guard manager.isAuthorizedForWidgetUpdates else {
            print("[Widget] Not authorized for widget updates")
            return nil
        }

        // 1. Try cached location first (no delegate round-trip needed)
        if let cached = manager.location {
            let age = abs(cached.timestamp.timeIntervalSinceNow)
            print("[Widget] Cached location: \(cached.coordinate.latitude), \(cached.coordinate.longitude), age=\(Int(age))s")
            if age < maxCacheAge {
                print("[Widget] Using cached location")
                return cached
            }
            print("[Widget] Cached location too old (\(Int(age))s > \(Int(maxCacheAge))s)")
        } else {
            print("[Widget] No cached location")
        }

        // 2. Fall back to requestLocation() via Combine
        print("[Widget] Calling requestLocation()...")
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        do {
            let location = try await requestLocationAsync(timeout: 10)
            print("[Widget] requestLocation succeeded: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            return location
        } catch {
            print("[Widget] requestLocation failed: \(error)")
            return nil
        }
    }

    // MARK: - Async bridge via Combine

    private enum FetchError: Error {
        case timeout
    }

    private func requestLocationAsync(timeout: TimeInterval) async throws -> CLLocation {
        try await withUnsafeThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            var didResume = false

            cancellable = subject
                .setFailureType(to: Error.self)
                .timeout(.seconds(timeout), scheduler: DispatchQueue.main, customError: { FetchError.timeout })
                .sink(
                    receiveCompletion: { completion in
                        guard !didResume else { return }
                        didResume = true
                        cancellable?.cancel()
                        if case .failure(let error) = completion {
                            continuation.resume(throwing: error)
                        }
                    },
                    receiveValue: { result in
                        guard !didResume else { return }
                        didResume = true
                        cancellable?.cancel()
                        switch result {
                        case .success(let location):
                            continuation.resume(returning: location)
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                    }
                )

            manager.requestLocation()
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        print("[Widget] didUpdateLocations: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        subject.send(.success(location))
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("[Widget] didFailWithError: \(error.localizedDescription)")
        subject.send(.failure(error))
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("[Widget] didChangeAuthorization: \(manager.authorizationStatus.rawValue)")
    }
}
