//
//  EventMapView.swift
//  CSNexus
//
//  Location-aware event discovery with map
//  Created by GitHub Copilot on 2025-10-05.
//

import SwiftUI
import MapKit

struct EventMapView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var clubEventManager = ClubEventManager()
    @State private var selectedEvent: ClubEvent?
    @State private var showingEventDetail = false
    @State private var mapRegion = MKCoordinateRegion(
        center: SFUCampus.burnabyCampusCenter,
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var showingLocationPermissionAlert = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                // Map with event pins
                Map(coordinateRegion: $mapRegion, showsUserLocation: true, annotationItems: upcomingEventsWithLocations) { eventPin in
                    MapAnnotation(coordinate: eventPin.coordinate) {
                        EventPinView(event: eventPin.event, distance: locationManager.calculateDistance(to: eventPin.event))
                            .onTapGesture {
                                selectedEvent = eventPin.event
                                showingEventDetail = true
                            }
                    }
                }
                .ignoresSafeArea(edges: .top)
                
                // Floating card showing nearby events
                if !nearbyEvents.isEmpty {
                    VStack(spacing: 0) {
                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 6) {
                                    Image(systemName: "mappin.circle.fill")
                                        .foregroundColor(.blue)
                                    Text("Events Near You")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                }
                                
                                Text("\(nearbyEvents.count) event\(nearbyEvents.count == 1 ? "" : "s") within 1 km")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            // Center on user button
                            Button(action: centerOnUser) {
                                Image(systemName: "location.fill")
                                    .font(.title3)
                                    .foregroundColor(.blue)
                                    .frame(width: 40, height: 40)
                                    .background(Color(.systemBackground))
                                    .clipShape(Circle())
                                    .shadow(radius: 2)
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        
                        Divider()
                        
                        // Scrollable event list
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(nearbyEvents) { event in
                                    NearbyEventCard(
                                        event: event,
                                        distance: locationManager.calculateDistance(to: event),
                                        onTap: {
                                            selectedEvent = event
                                            showingEventDetail = true
                                        },
                                        onNavigate: {
                                            openMapsForNavigation(to: event)
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                        }
                        .frame(height: 180)
                        .background(Color(.systemBackground))
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(16, corners: [.topLeft, .topRight])
                    .shadow(color: .black.opacity(0.1), radius: 10, y: -5)
                }
                
                // Location permission prompt
                if locationManager.authorizationStatus == .notDetermined {
                    VStack {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "location.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)
                            
                            Text("Enable Location")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("See events near you and get walking directions")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button(action: {
                                locationManager.requestLocationPermission()
                                locationManager.startTracking()
                            }) {
                                Text("Enable Location Services")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                        }
                        .padding(24)
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(radius: 10)
                        .padding()
                        Spacer()
                    }
                    .background(Color.black.opacity(0.3))
                }
            }
            .navigationTitle("Event Map")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                clubEventManager.loadEvents()
                locationManager.updateNearbyEvents(clubEventManager.upcomingEvents)
                
                if locationManager.authorizationStatus == .authorizedWhenInUse || 
                   locationManager.authorizationStatus == .authorizedAlways {
                    locationManager.startTracking()
                }
            }
            .sheet(item: $selectedEvent) { event in
                ClubEventDetailView(event: event, eventManager: clubEventManager)
            }
        }
    }
    
    // MARK: - Computed Properties
    private var upcomingEventsWithLocations: [EventPin] {
        clubEventManager.upcomingEvents.compactMap { event in
            guard let location = SFUCampus.getLocation(for: event.location),
                  event.location != "Online (Discord)" else {
                return nil
            }
            return EventPin(event: event, coordinate: location.coordinate)
        }
    }
    
    private var nearbyEvents: [ClubEvent] {
        locationManager.nearbyEvents
            .filter { $0.location != "Online (Discord)" }
            .prefix(5)
            .map { $0 }
    }
    
    // MARK: - Actions
    private func centerOnUser() {
        if let userLocation = locationManager.userLocation {
            withAnimation {
                mapRegion.center = userLocation.coordinate
            }
        }
    }
    
    private func openMapsForNavigation(to event: ClubEvent) {
        guard let location = SFUCampus.getLocation(for: event.location) else { return }
        
        let placemark = MKPlacemark(coordinate: location.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = event.title
        
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking
        ])
    }
}

// MARK: - Event Pin Model
struct EventPin: Identifiable {
    let id = UUID()
    let event: ClubEvent
    let coordinate: CLLocationCoordinate2D
}

// MARK: - Event Pin View
struct EventPinView: View {
    let event: ClubEvent
    let distance: CLLocationDistance?
    
    var pinColor: Color {
        switch event.eventType {
        case .hackathon: return .green
        case .competition: return .red
        case .workshop: return .blue
        case .networking: return .orange
        default: return .purple
        }
    }
    
    var body: some View {
        VStack(spacing: 4) {
            // Distance badge (if available)
            if let distance = distance {
                Text(distance.displayString)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(pinColor)
                    .cornerRadius(4)
            }
            
            // Pin icon
            ZStack {
                Circle()
                    .fill(pinColor)
                    .frame(width: 40, height: 40)
                    .shadow(radius: 3)
                
                Image(systemName: "mappin.circle.fill")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            
            // Event type badge
            Text(event.eventType.rawValue)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(pinColor.opacity(0.8))
                .cornerRadius(4)
        }
    }
}

// MARK: - Nearby Event Card
struct NearbyEventCard: View {
    let event: ClubEvent
    let distance: CLLocationDistance?
    let onTap: () -> Void
    let onNavigate: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Header with distance
                HStack {
                    EventTypeBadge(type: event.eventType)
                    
                    Spacer()
                    
                    if let distance = distance {
                        HStack(spacing: 4) {
                            Image(systemName: "figure.walk")
                                .font(.caption)
                            Text(locationManager.getWalkingTime(distance: distance))
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                Text(event.title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(event.location)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                // Navigate button
                Button(action: onNavigate) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.triangle.turn.up.right.circle.fill")
                        Text("Navigate")
                            .fontWeight(.semibold)
                    }
                    .font(.caption)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(12)
            .frame(width: 200)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var locationManager: LocationManager {
        LocationManager()
    }
}

// MARK: - Corner Radius Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    EventMapView()
}
