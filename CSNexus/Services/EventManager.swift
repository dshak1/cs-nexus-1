//
//  EventManager.swift
//  CSNexus
//
//  Created by GitHub Copilot on 2025-10-05.
//

import Foundation
import Combine

@MainActor
class EventManager: ObservableObject {
    @Published var upcomingEvents: [Event] = []
    @Published var pastEvents: [Event] = []
    @Published var myAttendance: [EventAttendance] = []
    @Published var connections: [Connection] = []
    
    init() {
        generateMockEvents()
        loadMyAttendance()
    }
    
    // MARK: - Event Discovery
    
    func generateMockEvents() {
        let now = Date()
        let calendar = Calendar.current
        
                // Upcoming events
        upcomingEvents = [
            Event(
                name: "nwHacks 2025",
                type: .hackathon,
                date: calendar.date(byAdding: .day, value: 7, to: now)!,
                organization: "UBC",
                location: "Vancouver, BC",
                attendees: 847,
                rsvpStatus: .none,
                mockAttendees: generateEventMockAttendees(count: 30, userCommonEvents: 4)
            ),
            Event(
                name: "Google Cloud Workshop",
                type: .workshop,
                date: calendar.date(byAdding: .day, value: 3, to: now)!,
                organization: "Google",
                location: "SFU Surrey",
                attendees: 124,
                rsvpStatus: .going,
                mockAttendees: generateEventMockAttendees(count: 25, userCommonEvents: 5)
            ),
            Event(
                name: "Meta Engineering Talk",
                type: .techTalk,
                date: calendar.date(byAdding: .day, value: 10, to: now)!,
                organization: "Meta",
                location: "Vancouver, BC",
                attendees: 256,
                rsvpStatus: .interested,
                mockAttendees: generateEventMockAttendees(count: 35, userCommonEvents: 3)
            ),
            Event(
                name: "SFU Career Fair 2025",
                type: .careerFair,
                date: calendar.date(byAdding: .day, value: 14, to: now)!,
                organization: "SFU",
                location: "Burnaby, BC",
                attendees: 1200,
                rsvpStatus: .going,
                mockAttendees: generateEventMockAttendees(count: 50, userCommonEvents: 4)
            ),
            Event(
                name: "AWS Cloud Workshop",
                type: .workshop,
                date: calendar.date(byAdding: .day, value: 21, to: now)!,
                organization: "Amazon",
                location: "Vancouver, BC",
                attendees: 180,
                rsvpStatus: .none,
                mockAttendees: generateEventMockAttendees(count: 28, userCommonEvents: 0)
            ),
            Event(
                name: "Stripe Office Tour",
                type: .officeTour,
                date: calendar.date(byAdding: .day, value: 28, to: now)!,
                organization: "Stripe",
                location: "Vancouver, BC",
                attendees: 45,
                rsvpStatus: .interested,
                mockAttendees: generateEventMockAttendees(count: 18, userCommonEvents: 2)
            )
        ]
        
        // Past events
        pastEvents = [
            Event(
                name: "StormHacks 2024",
                type: .hackathon,
                date: calendar.date(byAdding: .day, value: -2, to: now)!,
                organization: "SFU",
                location: "SFU Burnaby",
                attendees: 420,
                rsvpStatus: .none,
                hasAttended: true,
                mockAttendees: generateEventMockAttendees(count: 30, userCommonEvents: 5)
            ),
            Event(
                name: "CMD-F 2024",
                type: .hackathon,
                date: calendar.date(byAdding: .day, value: -30, to: now)!,
                organization: "nwPlus",
                location: "UBC Vancouver",
                attendees: 600,
                rsvpStatus: .none,
                hasAttended: true,
                mockAttendees: generateEventMockAttendees(count: 35, userCommonEvents: 4)
            ),
            Event(
                name: "Microsoft Azure Workshop",
                type: .workshop,
                date: calendar.date(byAdding: .day, value: -15, to: now)!,
                organization: "Microsoft",
                location: "SFU Surrey",
                attendees: 89,
                rsvpStatus: .none,
                hasAttended: true,
                mockAttendees: generateEventMockAttendees(count: 20, userCommonEvents: 3)
            ),
            Event(
                name: "HackTheNorth 2024",
                type: .hackathon,
                date: calendar.date(byAdding: .day, value: -45, to: now)!,
                organization: "University of Waterloo",
                location: "Waterloo, ON",
                attendees: 1000,
                rsvpStatus: .none,
                hasAttended: true,
                mockAttendees: generateEventMockAttendees(count: 40, userCommonEvents: 6)
            ),
            Event(
                name: "Amazon Networking Night",
                type: .networking,
                date: calendar.date(byAdding: .day, value: -8, to: now)!,
                organization: "Amazon",
                location: "Downtown Vancouver",
                attendees: 67,
                rsvpStatus: .none,
                hasAttended: true,
                mockAttendees: generateEventMockAttendees(count: 25, userCommonEvents: 2)
            )
        ]
    }
    
    // MARK: - Event Actions
    
    func registerForEvent(_ event: Event) {
        if let index = upcomingEvents.firstIndex(where: { $0.id == event.id }) {
            upcomingEvents[index].rsvpStatus = .going
            upcomingEvents[index].attendees += 1
        }
    }
    
    func unregisterFromEvent(_ event: Event) {
        if let index = upcomingEvents.firstIndex(where: { $0.id == event.id }) {
            upcomingEvents[index].rsvpStatus = .none
            upcomingEvents[index].attendees -= 1
        }
    }
    
    func updateRSVP(for event: Event, status: RSVPStatus) {
        if let index = upcomingEvents.firstIndex(where: { $0.id == event.id }) {
            upcomingEvents[index].rsvpStatus = status
        }
    }
    
    func checkInToEvent(_ event: Event) {
        // Simulate QR code check-in
        let attendance = EventAttendance(
            eventId: event.id,
            eventName: event.name,
            eventType: event.type,
            date: event.date,
            organization: event.organization
        )
        myAttendance.append(attendance)
        saveMyAttendance()
        
        if let index = upcomingEvents.firstIndex(where: { $0.id == event.id }) {
            upcomingEvents[index].hasAttended = true
        }
    }
    
    // MARK: - Networking
    
    func getAttendeesForEvent(_ eventId: UUID) -> [User] {
        // Mock attendees at an event
        return generateMockAttendees(count: Int.random(in: 15...50))
    }
    
    func generateMockConnections() {
        let calendar = Calendar.current
        let now = Date()
        
        let mockUsers = [
            ("Sarah Chen", "Computer Science", "4th Year", "Simon Fraser University", ["AI/ML", "Cloud Computing", "Python"]),
            ("Michael Torres", "Software Systems", "3rd Year", "Simon Fraser University", ["iOS Development", "SwiftUI", "Mobile Apps"]),
            ("Emily Zhang", "Computing Science", "2nd Year", "University of British Columbia", ["Web Dev", "React", "Node.js"]),
            ("Alex Kim", "Computer Engineering", "3rd Year", "Simon Fraser University", ["Systems", "C++", "Embedded"]),
            ("Jordan Lee", "Computer Science", "4th Year", "University of Waterloo", ["Backend", "Databases", "Go"]),
            ("Taylor Rivera", "Software Engineering", "2nd Year", "Simon Fraser University", ["Frontend", "UI/UX", "Design"])
        ]
        
        let eventNames = ["StormHacks 2024", "CMD-F 2024", "HackTheNorth 2024", "Microsoft Azure Workshop"]
        let eventTypes: [EventType] = [.hackathon, .hackathon, .hackathon, .workshop]
        
        for (index, user) in mockUsers.enumerated() {
            let daysAgo = Int.random(in: 2...45)
            let eventIndex = index % eventNames.count
            
            let connection = Connection(
                userId: UUID(),
                userName: user.0,
                userMajor: user.1,
                userYear: user.2,
                userSchool: user.3,
                userInterests: user.4,
                timestamp: calendar.date(byAdding: .day, value: -daysAgo, to: now)!,
                eventId: pastEvents.first?.id,
                eventName: eventNames[eventIndex],
                eventType: eventTypes[eventIndex],
                sharedEvents: Array(eventNames.prefix(Int.random(in: 1...3))),
                sharedInterests: user.4.filter { _ in Bool.random() }
            )
            connections.append(connection)
        }
        
        print("🎓 Generated \(connections.count) professional connections")
    }
    
    private func generateMockAttendees(count: Int) -> [User] {
        let firstNames = ["Alex", "Jordan", "Taylor", "Morgan", "Casey", "Riley", "Jamie", "Avery", "Quinn", "Skylar", "Dakota", "Sage", "River", "Phoenix", "Rowan"]
        let lastNames = ["Chen", "Patel", "Kim", "Singh", "Wang", "Kumar", "Lee", "Garcia", "Martinez", "Ahmed", "Ali", "Santos", "Liu", "Nguyen", "Rodriguez"]
        let majors = ["Computer Science", "Software Systems", "Computing Science", "Software Engineering", "Computer Engineering"]
        let years = ["2nd Year", "3rd Year", "4th Year", "Graduate"]
        let interests = ["AI/ML", "Web Dev", "Mobile Apps", "Cloud Computing", "Systems", "Backend", "Frontend", "Data Science"]
        
        return (0..<count).map { _ in
            User(
                name: "\(firstNames.randomElement()!) \(lastNames.randomElement()!)",
                major: majors.randomElement()!,
                year: years.randomElement()!,
                interests: Array(interests.shuffled().prefix(Int.random(in: 2...4)))
            )
        }
    }
    
    // MARK: - Mock Attendees Generation for Events
    
    func generateEventMockAttendees(count: Int, userCommonEvents: Int = 0) -> [Attendee] {
        let firstNames = ["Alex", "Jordan", "Taylor", "Morgan", "Casey", "Riley", "Jamie", "Avery", "Quinn", "Skylar", "Dakota", "Sage", "River", "Phoenix", "Rowan"]
        let lastNames = ["Chen", "Patel", "Kim", "Singh", "Wang", "Kumar", "Lee", "Garcia", "Martinez", "Ahmed", "Ali", "Santos", "Liu", "Nguyen", "Rodriguez"]
        let majors = ["Computer Science", "Software Engineering", "Data Science", "Cybersecurity", "Computer Engineering", "Information Systems"]
        let years = ["1st Year", "2nd Year", "3rd Year", "4th Year", "5th Year", "Masters", "PhD"]
        let emojis = ["👨‍💻", "👩‍💻", "🧑‍💻", "👨‍🎓", "👩‍🎓", "🧑‍🎓", "💻", "🚀", "⚡️", "🔥"]
        let bios = [
            "Passionate about building scalable systems",
            "Love hackathons and competitive programming",
            "Interested in AI/ML and data science",
            "Full-stack developer and open source contributor",
            "Cybersecurity enthusiast and CTF player",
            "Building the next big thing in tech"
        ]
        
        var attendees: [Attendee] = []
        
        for i in 0..<count {
            // Calculate common events count, ensuring valid ranges
            let commonEvents: Int
            if i < userCommonEvents / 2 {
                // First quarter have high common events (3-5)
                commonEvents = Int.random(in: 3...5)
            } else if i < userCommonEvents {
                // Next quarter have moderate common events (1-2)
                commonEvents = Int.random(in: 1...2)
            } else {
                // Rest have no common events
                commonEvents = 0
            }
            
            let attendee = Attendee(
                name: "\(firstNames.randomElement()!) \(lastNames.randomElement()!)",
                major: majors.randomElement()!,
                year: years.randomElement()!,
                avatarEmoji: emojis.randomElement()!,
                bio: bios.randomElement()!,
                commonEventsCount: commonEvents
            )
            
            attendees.append(attendee)
        }
        
        // Sort by common events count (people you've met first)
        return attendees.sorted { $0.commonEventsCount > $1.commonEventsCount }
    }
    
    // MARK: - Stats
    
    func getTotalEventsAttended() -> Int {
        pastEvents.filter { $0.hasAttended }.count
    }
    
    func getUpcomingEventsRegistered() -> Int {
        upcomingEvents.filter { $0.isAttending }.count
    }
    
    func getMostAttendedEventType() -> EventType? {
        let attendedEvents = pastEvents.filter { $0.hasAttended }
        let typeCounts = Dictionary(grouping: attendedEvents, by: { $0.type }).mapValues { $0.count }
        return typeCounts.max(by: { $0.value < $1.value })?.key
    }
    
    func getConnectionsThisMonth() -> Int {
        let calendar = Calendar.current
        let now = Date()
        let monthAgo = calendar.date(byAdding: .month, value: -1, to: now)!
        return connections.filter { $0.timestamp >= monthAgo }.count
    }
    
    // MARK: - Persistence
    
    private func saveMyAttendance() {
        if let encoded = try? JSONEncoder().encode(myAttendance) {
            UserDefaults.standard.set(encoded, forKey: "myEventAttendance")
        }
    }
    
    private func loadMyAttendance() {
        if let data = UserDefaults.standard.data(forKey: "myEventAttendance"),
           let decoded = try? JSONDecoder().decode([EventAttendance].self, from: data) {
            myAttendance = decoded
        }
    }
}
