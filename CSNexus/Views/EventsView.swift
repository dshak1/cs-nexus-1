//
//  EventsView.swift
//  CSNexus
//
//  Created by GitHub Copilot on 2025-10-05.
//

import SwiftUI
import UIKit

struct EventsView: View {
    @EnvironmentObject var eventManager: EventManager
    @State private var selectedTab = 0
    @State private var selectedEventId: UUID?
    @State private var showingEventDetail = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Segmented Control for Upcoming/Past
                Picker("Events", selection: $selectedTab) {
                    Text("Upcoming").tag(0)
                    Text("Past").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                if selectedTab == 0 {
                    upcomingEventsView
                } else {
                    pastEventsView
                }
            }
            .navigationTitle("Tech Events")
            .sheet(isPresented: $showingEventDetail) {
                if let eventId = selectedEventId {
                    EventDetailView(eventId: eventId)
                        .environmentObject(eventManager)
                }
            }
        }
    }
    
    private var upcomingEventsView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if eventManager.upcomingEvents.isEmpty {
                    emptyStateView(
                        icon: "calendar.badge.exclamationmark",
                        title: "No Upcoming Events",
                        subtitle: "Check back soon for new tech events!"
                    )
                } else {
                    ForEach(eventManager.upcomingEvents) { event in
                        EventCard(event: event, isPast: false)
                            .onTapGesture {
                                selectedEventId = event.id
                                showingEventDetail = true
                            }
                    }
                }
            }
            .padding()
        }
    }
    
    private var pastEventsView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if eventManager.pastEvents.isEmpty {
                    emptyStateView(
                        icon: "clock.badge.checkmark",
                        title: "No Past Events",
                        subtitle: "Events you attend will appear here"
                    )
                } else {
                    ForEach(eventManager.pastEvents) { event in
                        EventCard(event: event, isPast: true)
                            .onTapGesture {
                                selectedEventId = event.id
                                showingEventDetail = true
                            }
                    }
                }
            }
            .padding()
        }
    }
    
    private func emptyStateView(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

struct EventCard: View {
    let event: Event
    let isPast: Bool
    @EnvironmentObject var eventManager: EventManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with type badge
            HStack {
                Image(systemName: event.type.icon)
                    .foregroundColor(colorForType(event.type))
                
                Text(event.type.rawValue)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(colorForType(event.type))
                
                Spacer()
                
                if event.hasAttended {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            
            // Event name
            Text(event.name)
                .font(.headline)
                .fontWeight(.bold)
            
            // Organization and location
            HStack(spacing: 4) {
                Image(systemName: "building.2")
                    .font(.caption)
                Text(event.organization)
                    .font(.caption)
                
                Text("•")
                    .font(.caption)
                
                Image(systemName: "mappin.circle")
                    .font(.caption)
                Text(event.location)
                    .font(.caption)
            }
            .foregroundColor(.secondary)
            
            // Date and attendees
            HStack {
                Image(systemName: "calendar")
                    .font(.caption)
                Text(event.date, style: .date)
                    .font(.caption)
                
                Spacer()
                
                Image(systemName: "person.2")
                    .font(.caption)
                Text("\(event.attendees) attending")
                    .font(.caption)
            }
            .foregroundColor(.secondary)
            
            // Action button
            if !isPast {
                Button(action: {
                    if event.isAttending {
                        eventManager.unregisterFromEvent(event)
                    } else {
                        eventManager.registerForEvent(event)
                    }
                }) {
                    HStack {
                        Image(systemName: event.isAttending ? "checkmark.circle.fill" : "plus.circle.fill")
                        Text(event.isAttending ? "Registered" : "Register")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(event.isAttending ? Color.green : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding(.top, 4)
            } else if event.hasAttended {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Attended")
                        .foregroundColor(.green)
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    private func colorForType(_ type: EventType) -> Color {
        switch type {
        case .hackathon: return .blue
        case .workshop: return .orange
        case .techTalk: return .purple
        case .careerFair: return .green
        case .networking: return .pink
        case .officeTour: return .cyan
        case .competition: return .red
        case .conference: return .indigo
        }
    }
}

struct EventDetailView: View {
    let eventId: UUID
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var eventManager: EventManager
    @State private var showingAllAttendees = false
    
    // Get the current event from the manager (dynamically updates)
    private var event: Event? {
        eventManager.upcomingEvents.first(where: { $0.id == eventId }) ??
        eventManager.pastEvents.first(where: { $0.id == eventId })
    }
    
    var body: some View {
        NavigationView {
            if let event = event {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Event header
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: event.type.icon)
                                    .font(.title)
                                    .foregroundColor(colorForType(event.type))
                                
                                Spacer()
                                
                                if event.hasAttended {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.green)
                                }
                            }
                            
                            Text(event.name)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text(event.type.rawValue)
                                .font(.subheadline)
                                .foregroundColor(colorForType(event.type))
                        }
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(12)
                        
                        // Event details
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 12) {
                                Image(systemName: "calendar")
                                    .foregroundColor(.blue)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("When")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(event.date.formatted(date: .long, time: .shortened))
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
                            
                            HStack(spacing: 12) {
                                Image(systemName: "building.2")
                                    .foregroundColor(.green)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Organization")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(event.organization)
                                        .font(.subheadline)
                                }
                            }
                            
                            Divider()
                                .padding(.vertical, 4)
                            
                            // Add to Google Calendar
                            if let googleURL = CalendarExportManager.shared.generateGoogleCalendarURLForEvent(event) {
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
                            
                            HStack(spacing: 12) {
                                Image(systemName: "person.2")
                                    .foregroundColor(.purple)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Attendees")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("\(event.attendees) registered")
                                        .font(.subheadline)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    
                    // Action buttons (RSVP)
                    if !event.isPastEvent {
                        VStack(spacing: 12) {
                            Button(action: {
                                if event.isAttending {
                                    eventManager.unregisterFromEvent(event)
                                } else {
                                    eventManager.registerForEvent(event)
                                }
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.subheadline)
                                    Text(event.isAttending ? "Going ✓" : "I'm Going")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(event.isAttending ? Color.green : Color(.systemGray6))
                                .foregroundColor(event.isAttending ? .white : .primary)
                                .cornerRadius(12)
                            }
                            
                            Button(action: {
                                // TODO: Add interested functionality
                                print("📌 Marked as interested")
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "star.circle.fill")
                                        .font(.subheadline)
                                    Text("Interested")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemGray6))
                                .foregroundColor(.primary)
                                .cornerRadius(12)
                            }
                            
                            if event.isAttending {
                                Button(action: {
                                    eventManager.checkInToEvent(event)
                                }) {
                                    HStack {
                                        Image(systemName: "qrcode.viewfinder")
                                        Text("Check In (QR Code)")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Attendees preview with proper profiles
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Who's Attending")
                                .font(.headline)
                            
                            Spacer()
                            
                            Button(action: {
                                showingAllAttendees = true
                            }) {
                                Text("See All")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        if event.mockAttendees.filter({ $0.commonEventsCount > 0 }).count > 0 {
                            Text("\(event.mockAttendees.filter({ $0.commonEventsCount > 0 }).count) people you've met before • \(event.attendees) total")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        } else {
                            Text("Connect with \(event.attendees) other students")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        // Attendee profiles (sorted by common events)
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 16) {
                                ForEach(event.mockAttendees.prefix(12)) { attendee in
                                    AttendeePreviewCard(attendee: attendee)
                                        .environmentObject(eventManager)
                                }
                            }
                            .padding(.horizontal, 2)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                    
                        Spacer()
                    }
                    .padding()
                }
                .navigationTitle("Event Details")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
                .sheet(isPresented: $showingAllAttendees) {
                    AttendeeListView(event: event)
                        .environmentObject(eventManager)
                }
            } else {
                Text("Event not found")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func colorForType(_ type: EventType) -> Color {
        switch type {
        case .hackathon: return .blue
        case .workshop: return .orange
        case .techTalk: return .purple
        case .careerFair: return .green
        case .networking: return .pink
        case .officeTour: return .cyan
        case .competition: return .red
        case .conference: return .indigo
        }
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
    }
}

// MARK: - Attendee List View
struct AttendeeListView: View {
    let event: Event
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var eventManager: EventManager
    
    private var attendeesWithCommonEvents: Int {
        event.mockAttendees.filter { $0.commonEventsCount > 0 }.count
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Stats header
                    VStack(spacing: 8) {
                        Text("\(event.attendees) Attendees")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        if attendeesWithCommonEvents > 0 {
                            Text("\(attendeesWithCommonEvents) people you've met before")
                                .font(.subheadline)
                                .foregroundColor(.green)
                                .fontWeight(.semibold)
                        }
                    }
                    .padding(.top)
                    
                    // People you've met section
                    if attendeesWithCommonEvents > 0 {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("People You've Met")
                                    .font(.headline)
                                    .foregroundColor(.green)
                                
                                Spacer()
                                
                                Text("\(attendeesWithCommonEvents)")
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            
                            ForEach(event.mockAttendees.filter { $0.commonEventsCount > 0 }.sorted { $0.commonEventsCount > $1.commonEventsCount }) { attendee in
                                AttendeeCard(attendee: attendee)
                                    .environmentObject(eventManager)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // All attendees section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(attendeesWithCommonEvents > 0 ? "New Connections" : "All Attendees")
                                .font(.headline)
                            
                            Spacer()
                            
                            Text("\(event.mockAttendees.filter { $0.commonEventsCount == 0 }.count)")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        
                        ForEach(event.mockAttendees.filter { $0.commonEventsCount == 0 }) { attendee in
                            AttendeeCard(attendee: attendee)
                                .environmentObject(eventManager)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
            }
            .navigationTitle("Attendees (\(event.mockAttendees.count))")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AttendeeCard: View {
    let attendee: Attendee
    @State private var showingProfile = false
    @EnvironmentObject var eventManager: EventManager
    
    var body: some View {
        Button(action: {
            showingProfile = true
        }) {
            HStack(spacing: 12) {
                // Avatar emoji
                Text(attendee.avatarEmoji)
                    .font(.system(size: 40))
                    .frame(width: 60, height: 60)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    // Name with common events badge
                    HStack(spacing: 8) {
                        Text(attendee.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        if attendee.commonEventsCount > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption2)
                                Text("\(attendee.commonEventsCount) in common")
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green)
                            .cornerRadius(12)
                        }
                    }
                    
                    // Major and year
                    Text("\(attendee.major) • \(attendee.year)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Bio
                    Text(attendee.bio)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(attendee.commonEventsCount > 0 ? Color.green.opacity(0.05) : Color.gray.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(attendee.commonEventsCount > 0 ? Color.green.opacity(0.3) : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingProfile) {
            AttendeeProfileView(attendee: attendee)
                .environmentObject(eventManager)
        }
    }
}

// MARK: - Attendee Profile View
struct AttendeeProfileView: View {
    let attendee: Attendee
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var eventManager: EventManager
    
    // Generate synthetic profile data
    private var syntheticData: (linkedIn: String, github: String, skills: [String], interests: [String], commonEvents: [Event]) {
        let skills = [
            ["Python", "Django", "PostgreSQL"],
            ["React", "TypeScript", "Node.js"],
            ["Swift", "SwiftUI", "iOS"],
            ["Java", "Spring Boot", "AWS"],
            ["Go", "Docker", "Kubernetes"],
            ["C++", "Systems Programming", "Linux"]
        ].randomElement()!
        
        let interests = [
            ["Hackathons", "Open Source", "AI/ML"],
            ["Web Development", "UI/UX", "Design"],
            ["Mobile Apps", "Startups", "Entrepreneurship"],
            ["Backend Systems", "DevOps", "Cloud"],
            ["Competitive Programming", "Algorithms", "Math"],
            ["Cybersecurity", "CTF", "Cryptography"]
        ].randomElement()!
        
        // Get common events from past events
        let allEvents = eventManager.pastEvents + eventManager.upcomingEvents
        let commonEvents = allEvents.shuffled().prefix(attendee.commonEventsCount)
        
        return (
            linkedIn: "linkedin.com/in/\(attendee.name.lowercased().replacingOccurrences(of: " ", with: "-"))",
            github: "github.com/\(attendee.name.components(separatedBy: " ").first!.lowercased())\(Int.random(in: 100...999))",
            skills: skills,
            interests: interests,
            commonEvents: Array(commonEvents)
        )
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with avatar and name
                    VStack(spacing: 12) {
                        Text(attendee.avatarEmoji)
                            .font(.system(size: 80))
                            .frame(width: 120, height: 120)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(Circle())
                        
                        Text(attendee.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("\(attendee.major)")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("\(attendee.year)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                    
                    // Common Events Section (if any)
                    if attendee.commonEventsCount > 0 {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Events in Common")
                                    .font(.headline)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(syntheticData.commonEvents.prefix(3), id: \.id) { event in
                                    HStack {
                                        Image(systemName: event.type.icon)
                                            .foregroundColor(.blue)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(event.name)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                            Text(event.date, style: .date)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    // Bio Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "text.quote")
                                .foregroundColor(.blue)
                            Text("About")
                                .font(.headline)
                        }
                        
                        Text(attendee.bio)
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Skills Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "star.circle.fill")
                                .foregroundColor(.orange)
                            Text("Skills")
                                .font(.headline)
                        }
                        
                        FlowLayout(spacing: 8) {
                            ForEach(syntheticData.skills, id: \.self) { skill in
                                Text(skill)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(16)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Interests Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "heart.circle.fill")
                                .foregroundColor(.pink)
                            Text("Interests")
                                .font(.headline)
                        }
                        
                        FlowLayout(spacing: 8) {
                            ForEach(syntheticData.interests, id: \.self) { interest in
                                Text(interest)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.pink.opacity(0.1))
                                    .foregroundColor(.pink)
                                    .cornerRadius(16)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Social Links Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "link.circle.fill")
                                .foregroundColor(.purple)
                            Text("Connect")
                                .font(.headline)
                        }
                        
                        VStack(spacing: 8) {
                            SocialLinkButton(
                                icon: "person.crop.circle.fill",
                                title: "LinkedIn",
                                subtitle: syntheticData.linkedIn,
                                color: .blue,
                                url: "https://\(syntheticData.linkedIn)"
                            )
                            
                            SocialLinkButton(
                                icon: "chevron.left.forwardslash.chevron.right",
                                title: "GitHub",
                                subtitle: syntheticData.github,
                                color: .purple,
                                url: "https://\(syntheticData.github)"
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            // TODO: Send connection request
                            print("🤝 Connection request sent to \(attendee.name)")
                        }) {
                            HStack {
                                Image(systemName: "person.badge.plus")
                                Text("Send Connection Request")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        
                        Button(action: {
                            // TODO: Send message
                            print("💬 Message sent to \(attendee.name)")
                        }) {
                            HStack {
                                Image(systemName: "message")
                                Text("Send Message")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray5))
                            .foregroundColor(.primary)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct SocialLinkButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let url: String
    
    var body: some View {
        Button(action: {
            if let url = URL(string: url) {
                UIApplication.shared.open(url)
            }
        }) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FlowLayout: Layout {
    let spacing: CGFloat
    
    init(spacing: CGFloat = 8) {
        self.spacing = spacing
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: result.positions[index], proposal: ProposedViewSize(result.sizes[index]))
        }
    }
    
    struct FlowResult {
        let size: CGSize
        let positions: [CGPoint]
        let sizes: [CGSize]
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var sizes: [CGSize] = []
            var positions: [CGPoint] = []
            
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    // Move to next line
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: currentX, y: currentY))
                sizes.append(size)
                
                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }
            
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
            self.positions = positions
            self.sizes = sizes
        }
    }
}

// MARK: - Attendee Preview Card (for horizontal scroll)
struct AttendeePreviewCard: View {
    let attendee: Attendee
    @State private var showingProfile = false
    @EnvironmentObject var eventManager: EventManager
    
    var body: some View {
        Button(action: {
            showingProfile = true
        }) {
            VStack(spacing: 8) {
                // Avatar with green border if common events
                ZStack(alignment: .topTrailing) {
                    Text(attendee.avatarEmoji)
                        .font(.system(size: 40))
                        .frame(width: 70, height: 70)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(attendee.commonEventsCount > 0 ? Color.green : Color.clear, lineWidth: 3)
                        )
                    
                    // Badge for common events
                    if attendee.commonEventsCount > 0 {
                        ZStack {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 24, height: 24)
                            
                            Text("\(attendee.commonEventsCount)")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .offset(x: 5, y: -5)
                    }
                }
                
                // Name
                Text(attendee.name.components(separatedBy: " ").first ?? attendee.name)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                // Major
                Text(attendee.major)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .frame(width: 80)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingProfile) {
            AttendeeProfileView(attendee: attendee)
                .environmentObject(eventManager)
        }
    }
}

#Preview {
    EventsView()
        .environmentObject(EventManager())
}
