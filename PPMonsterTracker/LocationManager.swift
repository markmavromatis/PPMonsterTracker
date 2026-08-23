//
//  LocationManager.swift
//  PPMonsterTracker
//
//  Created by Mark Mavromatis on 8/12/26.
//

import CoreLocation
import Observation

@Observable
final class LocationManager {
    private let manager = CLLocationManager()
    // Separate NSObject subclass for the delegate avoids @Observable + NSObject conflicts.
    private var delegate: Delegate?

    var coordinate: CLLocationCoordinate2D?
    var authorizationStatus: CLAuthorizationStatus = .notDetermined

    init() {
        let d = Delegate()
        d.owner = self
        delegate = d
        manager.delegate = d
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        authorizationStatus = manager.authorizationStatus
    }

    func requestLocation() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        default:
            break
        }
    }

    private final class Delegate: NSObject, CLLocationManagerDelegate {
        weak var owner: LocationManager?

        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            owner?.coordinate = locations.last?.coordinate
        }

        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {}

        func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            owner?.authorizationStatus = manager.authorizationStatus
            if manager.authorizationStatus == .authorizedWhenInUse ||
               manager.authorizationStatus == .authorizedAlways {
                manager.requestLocation()
            }
        }
    }
}
