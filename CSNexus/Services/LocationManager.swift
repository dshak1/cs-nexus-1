//
//  LocationManager.swift
//  CSNexus
//
//  Location-based features for on-the-go students
//  Created by GitHub Copilot on 2025-10-05.
//

import Foundation
import CoreLocation
import Combine

// MARK: - Campus Location Data
struct CampusLocation: Identifiable {
    let id = UUID()
    let buildingCode: String
    let buildingName: String
    let roomNumber: String?
    let coordinate: CLLocationCoordinate2D
    
    var fullAddress: String {
        if let room = roomNumber {
            return "\(buildingCode) \(room)"
        }
        return buildingCode
    }
}

// MARK: - SFU Campus Buildings
struct SFUCampus {
    // SFU Burnaby Campus coordinates (main campus center)
    static let burnabyCampusCenter = CLLocationCoordinate2D(latitude: 49.2781, longitude: -122.9199)
    
    static let buildings: [String: CampusLocation] = [
        "TASC 1 9204": CampusLocation(
            buildingCode: "TASC 1",
            buildingName: "Technology and Science Complex 1",
            roomNumber: "9204",
            coordinate: CLLocationCoordinate2D(latitude: 49.2781, longitude: -122.9199)
        ),
        "AQ 3149": CampusLocation(
            buildingCode: "AQ",
            buildingName: "Academic Quadrangle",
            roomNumber: "3149",
            coordinate: CLLocationCoordinate2D(latitude: 49.2795, longitude: -122.9183)
        ),
        "AQ 4140": CampusLocation(
            buildingCode: "AQ",
            buildingName: "Academic Quadrangle",
            roomNumber: "4140",
            coordinate: CLLocationCoordinate2D(latitude: 49.2795, longitude: -122.9183)
        ),
        "MBC Gymnasium": CampusLocation(
            buildingCode: "MBC",
            buildingName: "Multi-Purpose Building Complex",
            roomNumber: "Gymnasium",
            coordinate: CLLocationCoordinate2D(latitude: 49.2767, longitude: -122.9180)
        ),
        "CSIL (TASC 1 9200)": CampusLocation(
            buildingCode: "TASC 1",
            buildingName: "Computer Science Instructional Lab",
            roomNumber: "9200",
            coordinate: CLLocationCoordinate2D(latitude: 49.2781, longitude: -122.9199)
        ),
        "SFU Surrey Campus - Building A": CampusLocation(
            buildingCode: "Surrey",
            buildingName: "SFU Surrey Campus",
            roomNumber: "Building A",
            coordinate: CLLocationCoordinate2D(latitude: 49.1876, longitude: -122.8489)
        ),
        "Online (Discord)": CampusLocation(
            buildingCode: "Online",
            buildingName: "Virtual Event",
            roomNumber: nil,
            coordinate: CLLocationCoordinate2D(latitude: 49.2781, longitude: -122.9199) // Default to campus center
        )
    ]
    
    static func getLocation(for address: String) -> CampusLocation? {
        // Try exact match first
        if let location = buildings[address] {
            return location
        }
        
        // Try partial match
        for (key, location) in buildings {
            if key.contains(address) || address.contains(key) {
                return location
            }
        }
        
        return nil
    }
}

// MARK: - Location Manager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var userLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var nearbyEvents: [ClubEvent] = []
    
    private let locationManager = CLLocationManager()
    private var allEvents: [ClubEvent] = []
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 50 // Update every 50 meters
        authorizationStatus = locationManager.authorizationStatus
    }
    
    func requestLocationPermission() {
        Task { @MainActor in
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func startTracking() {
        Task { @MainActor in
            if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
                locationManager.startUpdatingLocation()
            }
        }
    }
    
    func stopTracking() {
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - Distance Calculations
    func calculateDistance(to event: ClubEvent) -> CLLocationDistance? {
        guard let userLocation = userLocation,
              let eventLocation = SFUCampus.getLocation(for: event.location) else {
            return nil
        }
        
        let eventCLLocation = CLLocation(
            latitude: eventLocation.coordinate.latitude,
            longitude: eventLocation.coordinate.longitude
        )
        
        return userLocation.distance(from: eventCLLocation)
    }
    
    func getWalkingTime(distance: CLLocationDistance) -> String {
        let minutes = Int(distance / 80) // Average walking speed ~80m/min
        if minutes < 1 {
            return "< 1 min walk"
        } else if minutes == 1 {
            return "1 min walk"
        } else {
            return "\(minutes) min walk"
        }
    }
    
    func isNearby(_ event: ClubEvent, threshold: CLLocationDistance = 500) -> Bool {
        guard let distance = calculateDistance(to: event) else {
            return false
        }
        return distance <= threshold
    }
    
    // MARK: - Update Nearby Events
    func updateNearbyEvents(_ events: [ClubEvent]) {
        allEvents = events
        refreshNearbyEvents()
    }
    
    private func refreshNearbyEvents() {
        nearbyEvents = allEvents
            .filter { isNearby($0, threshold: 1000) } // Within 1km
            .sorted { (calculateDistance(to: $0) ?? Double.infinity) < (calculateDistance(to: $1) ?? Double.infinity) }
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            authorizationStatus = manager.authorizationStatus
            
            if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
                startTracking()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            guard let location = locations.last else { return }
            userLocation = location
            refreshNearbyEvents()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location error: \(error.localizedDescription)")
    }
}

// MARK: - Distance Extension for Display
extension CLLocationDistance {
    var displayString: String {
        if self < 1000 {
            return String(format: "%.0f m", self)
        } else {
            return String(format: "%.1f km", self / 1000)
        }
    }
}
