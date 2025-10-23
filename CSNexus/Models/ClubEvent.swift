//
//  ClubEvent.swift
//  CSNexus
//
//  Club and tech events for CS students
//  Created by GitHub Copilot on 2025-10-05.
//

import Foundation

// MARK: - Club Event Models
struct ClubEvent: Identifiable, Codable {
    let id: UUID
    let title: String
    let clubName: String
    let eventType: EventType
    let description: String
    let location: String
    let startTime: Date
    let endTime: Date
    var attendees: [Attendee]
    var status: EventStatus
    let tags: [String]
    let imageURL: String?
    
    enum EventType: String, Codable, CaseIterable {
        case workshop = "Workshop"
        case competition = "Competition"
        case generalMeeting = "General Meeting"
        case hackathon = "Hackathon"
        case networking = "Networking"
        case seminar = "Seminar"
        case socialEvent = "Social"
    }
    
    enum EventStatus: String, Codable {
        case upcoming, ongoing, completed
    }
    
    struct Attendee: Identifiable, Codable, Hashable {
        let id: UUID
        let name: String
        let avatarEmoji: String
        var rsvpStatus: RSVPStatus
        let major: String
        let year: String
        let bio: String
        let leetcodeUsername: String?
        let githubUsername: String?
        let linkedinUsername: String?
        var commonEventCount: Int = 0 // Number of shared events with current user
        
        // Computed property for sorting
        var hasMetBefore: Bool {
            commonEventCount > 0
        }
    }
    
    enum RSVPStatus: String, Codable {
        case going, interested, notGoing
    }
    
    var isUpcoming: Bool {
        status == .upcoming && startTime > Date()
    }
    
    var isOngoing: Bool {
        status == .ongoing || (startTime <= Date() && endTime >= Date())
    }
    
    var isPast: Bool {
        status == .completed || endTime < Date()
    }
    
    var attendeeCount: Int {
        attendees.filter { $0.rsvpStatus == .going }.count
    }
    
    var interestedCount: Int {
        attendees.filter { $0.rsvpStatus == .interested }.count
    }
}

// MARK: - Club Information
struct Club: Identifiable, Codable {
    let id: UUID
    let name: String
    let acronym: String
    let description: String
    let category: ClubCategory
    let memberCount: Int
    let instagram: String?
    let discord: String?
    
    enum ClubCategory: String, Codable {
        case competitive = "Competitive Programming"
        case general = "General CS"
        case security = "Cybersecurity"
        case career = "Career Development"
        case hardware = "Hardware/Robotics"
        case ai = "AI/ML"
    }
}
