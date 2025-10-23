//
//  Event.swift
//  CSNexus
//
//  Created by GitHub Copilot on 2025-10-05.
//

import Foundation

struct Event: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let type: EventType
    let date: Date
    let organization: String
    let location: String
    var attendees: Int
    var rsvpStatus: RSVPStatus
    var hasAttended: Bool
    var mockAttendees: [Attendee]
    
    init(
        id: UUID = UUID(),
        name: String,
        type: EventType,
        date: Date,
        organization: String,
        location: String,
        attendees: Int = 0,
        rsvpStatus: RSVPStatus = .none,
        hasAttended: Bool = false,
        mockAttendees: [Attendee] = []
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.date = date
        self.organization = organization
        self.location = location
        self.attendees = attendees
        self.rsvpStatus = rsvpStatus
        self.hasAttended = hasAttended
        self.mockAttendees = mockAttendees
    }
    
    var isPastEvent: Bool {
        date < Date()
    }
    
    var isUpcoming: Bool {
        !isPastEvent
    }
    
    var isAttending: Bool {
        rsvpStatus == .going
    }
}

enum EventType: String, Codable, CaseIterable {
    case hackathon = "Hackathon"
    case workshop = "Workshop"
    case techTalk = "Tech Talk"
    case careerFair = "Career Fair"
    case networking = "Networking"
    case officeTour = "Office Tour"
    case competition = "Competition"
    case conference = "Conference"
    
    var icon: String {
        switch self {
        case .hackathon:
            return "hammer.fill"
        case .workshop:
            return "wrench.and.screwdriver.fill"
        case .techTalk:
            return "person.wave.2.fill"
        case .careerFair:
            return "briefcase.fill"
        case .networking:
            return "person.3.fill"
        case .officeTour:
            return "building.2.fill"
        case .competition:
            return "trophy.fill"
        case .conference:
            return "microphone.fill"
        }
    }
    
    var color: String {
        switch self {
        case .hackathon:
            return "blue"
        case .workshop:
            return "orange"
        case .techTalk:
            return "purple"
        case .careerFair:
            return "green"
        case .networking:
            return "pink"
        case .officeTour:
            return "cyan"
        case .competition:
            return "red"
        case .conference:
            return "indigo"
        }
    }
}

struct EventAttendance: Identifiable, Codable {
    let id: UUID
    let eventId: UUID
    let eventName: String
    let eventType: EventType
    let date: Date
    let organization: String
    
    init(
        id: UUID = UUID(),
        eventId: UUID,
        eventName: String,
        eventType: EventType,
        date: Date,
        organization: String
    ) {
        self.id = id
        self.eventId = eventId
        self.eventName = eventName
        self.eventType = eventType
        self.date = date
        self.organization = organization
    }
}
