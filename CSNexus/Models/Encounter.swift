//
//  Encounter.swift
//  CSNexus
//
//  Created by GitHub Copilot on 2025-10-04.
//

import Foundation

// Renamed to Connection - represents professional connections made at events
struct Connection: Identifiable, Codable {
    let id = UUID()
    let userId: UUID
    let userName: String
    let userMajor: String
    let userYear: String
    let userSchool: String
    let userInterests: [String]
    let timestamp: Date
    let eventId: UUID?
    let eventName: String?
    let eventType: EventType?
    let sharedEvents: [String] // Names of mutual events attended
    let sharedInterests: [String]
    var notes: String?
    
    init(
        user: User,
        eventId: UUID? = nil,
        eventName: String? = nil,
        eventType: EventType? = nil,
        sharedEvents: [String] = [],
        sharedInterests: [String] = [],
        notes: String? = nil
    ) {
        self.userId = user.id
        self.userName = user.name
        self.userMajor = user.major
        self.userYear = user.year
        self.userSchool = user.school
        self.userInterests = user.interests
        self.timestamp = Date()
        self.eventId = eventId
        self.eventName = eventName
        self.eventType = eventType
        self.sharedEvents = sharedEvents
        self.sharedInterests = sharedInterests
        self.notes = notes
    }
    
    // Custom initializer for mock data
    init(
        userId: UUID,
        userName: String,
        userMajor: String,
        userYear: String,
        userSchool: String,
        userInterests: [String],
        timestamp: Date,
        eventId: UUID?,
        eventName: String?,
        eventType: EventType?,
        sharedEvents: [String],
        sharedInterests: [String],
        notes: String? = nil
    ) {
        self.userId = userId
        self.userName = userName
        self.userMajor = userMajor
        self.userYear = userYear
        self.userSchool = userSchool
        self.userInterests = userInterests
        self.timestamp = timestamp
        self.eventId = eventId
        self.eventName = eventName
        self.eventType = eventType
        self.sharedEvents = sharedEvents
        self.sharedInterests = sharedInterests
        self.notes = notes
    }
    
    var timeAgoString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
    
    var connectionContext: String {
        if let eventName = eventName {
            return "Met at \(eventName)"
        } else if !sharedEvents.isEmpty {
            return "Both attended \(sharedEvents.first!)"
        } else {
            return "Connection"
        }
    }
}

// Keep Encounter for backward compatibility during migration
typealias Encounter = Connection