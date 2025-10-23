//
//  ClubEventsView.swift
//  CSNexus
//
//  Browse and RSVP to club events
//  Created by GitHub Copilot on 2025-10-05.
//

import SwiftUI
import MapKit

struct ClubEventsView: View {
    @StateObject private var eventManager = ClubEventManager()
    @State private var selectedTab: EventTab = .upcoming
    @State private var selectedEvent: ClubEvent?
    
    enum EventTab: String, CaseIterable {
        case upcoming = "Upcoming"
        case ongoing = "Live Now"
        case past = "Past"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Selector
                Picker("Event Status", selection: $selectedTab) {
                    ForEach(EventTab.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Event List
                ScrollView {
                    VStack(spacing: 16) {
                        switch selectedTab {
                        case .upcoming:
                            if eventManager.upcomingEvents.isEmpty {
                                emptyStateView(message: "No upcoming events")
                            } else {
                                ForEach(eventManager.upcomingEvents) { event in
                                    ClubEventCard(
                                        event: event,
                                        userRSVP: eventManager.getUserRSVP(for: event.id),
                                        onRSVP: { status in
                                            eventManager.updateRSVP(eventId: event.id, status: status)
                                        }
                                    )
                                    .onTapGesture {
                                        selectedEvent = event
                                    }
                                }
                            }
                            
                        case .ongoing:
                            if eventManager.ongoingEvents.isEmpty {
                                emptyStateView(message: "No events happening right now")
                            } else {
                                ForEach(eventManager.ongoingEvents) { event in
                                    ClubEventCard(
                                        event: event,
                                        userRSVP: eventManager.getUserRSVP(for: event.id),
                                        onRSVP: { status in
                                            eventManager.updateRSVP(eventId: event.id, status: status)
                                        }
                                    )
                                    .onTapGesture {
                                        selectedEvent = event
                                    }
                                }
                            }
                            
                        case .past:
                            if eventManager.pastEvents.isEmpty {
                                emptyStateView(message: "No past events")
                            } else {
                                ForEach(eventManager.pastEvents) { event in
                                    ClubEventCard(
                                        event: event,
                                        userRSVP: eventManager.getUserRSVP(for: event.id),
                                        onRSVP: { status in
                                            eventManager.updateRSVP(eventId: event.id, status: status)
                                        }
                                    )
                                    .onTapGesture {
                                        selectedEvent = event
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Club Events")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                eventManager.loadEvents()
            }
            .sheet(item: $selectedEvent) { event in
                ClubEventDetailView(event: event, eventManager: eventManager)
            }
        }
    }
    
    private func emptyStateView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text(message)
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
    }
}

// MARK: - Club Event Card
struct ClubEventCard: View {
    let event: ClubEvent
    let userRSVP: ClubEvent.RSVPStatus?
    let onRSVP: (ClubEvent.RSVPStatus) -> Void
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with club name and event type
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.clubName)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    
                    Text(event.title)
                        .font(.headline)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                EventTypeBadge(type: event.eventType)
            }
            
            // Distance badge (if location enabled and not online)
            if let distance = locationManager.calculateDistance(to: event),
               event.location != "Online (Discord)" {
                HStack(spacing: 4) {
                    Image(systemName: "figure.walk")
                        .font(.caption)
                    Text("\(distance.displayString) • \(locationManager.getWalkingTime(distance: distance))")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.blue)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
            
            // Status indicator for ongoing events
            if event.isOngoing {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                    Text("LIVE NOW")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
            }
            
            // Time and location
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatDate(event.startTime))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 6) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(event.location)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // Tags
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(event.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.purple.opacity(0.1))
                            .foregroundColor(.purple)
                            .cornerRadius(4)
                    }
                }
            }
            
            // Attendees
            HStack(spacing: 8) {
                // Avatars
                HStack(spacing: -8) {
                    ForEach(event.attendees.prefix(5)) { attendee in
                        Text(attendee.avatarEmoji)
                            .font(.caption)
                            .frame(width: 28, height: 28)
                            .background(Color(.systemGray6))
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color(.systemBackground), lineWidth: 2)
                            )
                    }
                }
                
                Text("\(event.attendeeCount) going")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if event.interestedCount > 0 {
                    Text("• \(event.interestedCount) interested")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // RSVP Buttons (only for upcoming events)
            if event.isUpcoming {
                HStack(spacing: 12) {
                    RSVPButton(
                        icon: "checkmark.circle.fill",
                        label: "Going",
                        isSelected: userRSVP == .going,
                        color: .green
                    ) {
                        onRSVP(userRSVP == .going ? .notGoing : .going)
                    }
                    
                    RSVPButton(
                        icon: "star.circle.fill",
                        label: "Interested",
                        isSelected: userRSVP == .interested,
                        color: .orange
                    ) {
                        onRSVP(userRSVP == .interested ? .notGoing : .interested)
                    }
                }
            }
            
            // Past event indicator
            if event.isPast {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.gray)
                    Text("Event Completed")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter.string(from: date)
    }
}

// MARK: - Event Type Badge
struct EventTypeBadge: View {
    let type: ClubEvent.EventType
    
    var color: Color {
        switch type {
        case .workshop: return .blue
        case .competition: return .red
        case .generalMeeting: return .purple
        case .hackathon: return .green
        case .networking: return .orange
        case .seminar: return .indigo
        case .socialEvent: return .pink
        }
    }
    
    var body: some View {
        Text(type.rawValue)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(8)
    }
}

// MARK: - RSVP Button
struct RSVPButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.subheadline)
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(isSelected ? color : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(10)
        }
    }
}

// MARK: - Club Event Detail View
struct ClubEventDetailView: View {
    let event: ClubEvent
    let eventManager: ClubEventManager
    @Environment(\.dismiss) var dismiss
    @State private var selectedAttendee: ClubEvent.Attendee?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            EventTypeBadge(type: event.eventType)
                            Spacer()
                            if event.isOngoing {
                                HStack(spacing: 6) {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 8, height: 8)
                                    Text("LIVE NOW")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        
                        Text(event.title)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(event.clubName)
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    
                    // Time and Location
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 12) {
                            Image(systemName: "calendar")
                                .foregroundColor(.blue)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("When")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(formatDateRange(start: event.startTime, end: event.endTime))
                                    .font(.subheadline)
                            }
                        }
                        
                        HStack(spacing: 12) {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.red)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Where")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(event.location)
                                    .font(.subheadline)
                            }
                        }
                        
                        Divider()
                            .padding(.vertical, 4)
                        
                        // Get Directions button (if not online)
                        if event.location != "Online (Discord)",
                           let location = SFUCampus.getLocation(for: event.location) {
                            Button(action: {
                                openMapsForNavigation(to: location, eventName: event.title)
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "arrow.triangle.turn.up.right.circle.fill")
                                        .font(.subheadline)
                                    Text("Get Directions")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                        }
                        
                        // Add to Google Calendar
                        if let googleURL = CalendarExportManager.shared.generateGoogleCalendarURL(for: event) {
                            Link(destination: googleURL) {
                                HStack(spacing: 8) {
                                    Image(systemName: "calendar.badge.plus")
                                        .font(.subheadline)
                                    Text("Add to Google Calendar")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About")
                            .font(.headline)
                        Text(event.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    // Tags
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tags")
                            .font(.headline)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(event.tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.subheadline)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.purple.opacity(0.1))
                                        .foregroundColor(.purple)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    
                    // Attendees
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Attendees")
                                .font(.headline)
                            Spacer()
                            Text("\(event.attendeeCount) going")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        // People you've met before
                        let metBefore = event.attendees.filter { $0.hasMetBefore }
                        if !metBefore.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "person.2.fill")
                                        .foregroundColor(.green)
                                    Text("People you've met (\(metBefore.count))")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.green)
                                }
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(metBefore) { attendee in
                                            Button(action: {
                                                selectedAttendee = attendee
                                            }) {
                                                VStack(spacing: 6) {
                                                    ZStack(alignment: .topTrailing) {
                                                        Text(attendee.avatarEmoji)
                                                            .font(.system(size: 32))
                                                            .frame(width: 70, height: 70)
                                                            .background(Color.green.opacity(0.1))
                                                            .clipShape(Circle())
                                                            .overlay(
                                                                Circle()
                                                                    .stroke(Color.green, lineWidth: 2.5)
                                                            )
                                                        
                                                        // Badge showing common events
                                                        Text("\(attendee.commonEventCount)")
                                                            .font(.caption2)
                                                            .fontWeight(.bold)
                                                            .foregroundColor(.white)
                                                            .frame(width: 22, height: 22)
                                                            .background(Color.green)
                                                            .clipShape(Circle())
                                                            .offset(x: 8, y: -8)
                                                    }
                                                    .padding(.top, 10) // Add padding for badge
                                                    
                                                    Text(attendee.name.components(separatedBy: " ").first ?? attendee.name)
                                                        .font(.caption)
                                                        .fontWeight(.medium)
                                                        .foregroundColor(.primary)
                                                        .lineLimit(1)
                                                        .frame(width: 80)
                                                }
                                            }
                                        }
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.top, 4) // Extra top padding for badges
                                }
                            }
                            .padding(.bottom, 8)
                        }
                        
                        // All attendees
                        Text("All Attendees")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                            ForEach(event.attendees.prefix(20)) { attendee in
                                Button(action: {
                                    selectedAttendee = attendee
                                }) {
                                    VStack(spacing: 4) {
                                        Text(attendee.avatarEmoji)
                                            .font(.title2)
                                            .frame(width: 50, height: 50)
                                            .background(attendee.hasMetBefore ? Color.green.opacity(0.1) : Color(.systemGray6))
                                            .clipShape(Circle())
                                            .overlay(
                                                Circle()
                                                    .stroke(attendee.hasMetBefore ? Color.green : Color.clear, lineWidth: 1.5)
                                            )
                                        
                                        Text(attendee.name.components(separatedBy: " ").first ?? attendee.name)
                                            .font(.caption2)
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                    }
                                }
                            }
                        }
                    }
                    
                    // RSVP Buttons
                    if event.isUpcoming {
                        VStack(spacing: 12) {
                            RSVPButton(
                                icon: "checkmark.circle.fill",
                                label: "I'm Going",
                                isSelected: eventManager.getUserRSVP(for: event.id) == .going,
                                color: .green
                            ) {
                                let newStatus: ClubEvent.RSVPStatus = eventManager.getUserRSVP(for: event.id) == .going ? .notGoing : .going
                                eventManager.updateRSVP(eventId: event.id, status: newStatus)
                            }
                            
                            RSVPButton(
                                icon: "star.circle.fill",
                                label: "Interested",
                                isSelected: eventManager.getUserRSVP(for: event.id) == .interested,
                                color: .orange
                            ) {
                                let newStatus: ClubEvent.RSVPStatus = eventManager.getUserRSVP(for: event.id) == .interested ? .notGoing : .interested
                                eventManager.updateRSVP(eventId: event.id, status: newStatus)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $selectedAttendee) { attendee in
                AttendeeProfileView(attendee: attendee)
            }
        }
    }
    
    private func formatDateRange(start: Date, end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        let startStr = formatter.string(from: start)
        
        formatter.dateFormat = "h:mm a"
        let endStr = formatter.string(from: end)
        
        return "\(startStr) - \(endStr)"
    }
    
    private func openMapsForNavigation(to location: CampusLocation, eventName: String) {
        let placemark = MKPlacemark(coordinate: location.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = eventName
        
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking
        ])
    }
}

#Preview {
    ClubEventsView()
}
