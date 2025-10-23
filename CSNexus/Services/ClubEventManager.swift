//
//  ClubEventManager.swift
//  CSNexus
//
//  Manages club events and RSVPs
//  Created by GitHub Copilot on 2025-10-05.
//

import Foundation
import Combine

@MainActor
class ClubEventManager: ObservableObject {
    @Published var upcomingEvents: [ClubEvent] = []
    @Published var ongoingEvents: [ClubEvent] = []
    @Published var pastEvents: [ClubEvent] = []
    @Published var userRSVPs: [UUID: ClubEvent.RSVPStatus] = [:] // eventId -> RSVP status
    
    func loadEvents() {
        let mockEvents = generateMockEvents()
        
        upcomingEvents = mockEvents.filter { $0.isUpcoming }
        ongoingEvents = mockEvents.filter { $0.isOngoing }
        pastEvents = mockEvents.filter { $0.isPast }
    }
    
    func updateRSVP(eventId: UUID, status: ClubEvent.RSVPStatus) {
        userRSVPs[eventId] = status
        
        // Update the event's attendee list
        if let index = upcomingEvents.firstIndex(where: { $0.id == eventId }) {
            // In real app, this would sync with backend
            print("📅 RSVP updated for event: \(upcomingEvents[index].title) - Status: \(status.rawValue)")
        }
    }
    
    func getUserRSVP(for eventId: UUID) -> ClubEvent.RSVPStatus? {
        return userRSVPs[eventId]
    }
    
    // MARK: - Mock Data Generation
    private func generateMockEvents() -> [ClubEvent] {
        let currentDate = Date()
        
        return [
            // Upcoming Events
            ClubEvent(
                id: UUID(),
                title: "StormHacks 2025",
                clubName: "SFU Surge",
                eventType: .hackathon,
                description: "SFU's largest 24-hour hackathon! Build innovative projects, win prizes, and network with industry professionals.",
                location: "SFU Surrey Campus - Building A",
                startTime: currentDate.addingTimeInterval(7 * 24 * 60 * 60), // 7 days from now
                endTime: currentDate.addingTimeInterval(8 * 24 * 60 * 60),
                attendees: generateAttendees(count: 247),
                status: .upcoming,
                tags: ["Hackathon", "Prizes", "Free Food", "Beginner Friendly"],
                imageURL: nil
            ),
            ClubEvent(
                id: UUID(),
                title: "Competitive Programming Weekly",
                clubName: "SFU ICPC Club",
                eventType: .competition,
                description: "Practice LeetCode-style problems in a competitive setting. All skill levels welcome!",
                location: "TASC 1 9204",
                startTime: currentDate.addingTimeInterval(2 * 24 * 60 * 60), // 2 days
                endTime: currentDate.addingTimeInterval(2 * 24 * 60 * 60 + 2 * 60 * 60),
                attendees: generateAttendees(count: 42),
                status: .upcoming,
                tags: ["Algorithms", "Competition", "Prizes"],
                imageURL: nil
            ),
            ClubEvent(
                id: UUID(),
                title: "Resume & Interview Workshop",
                clubName: "CSSS Career Committee",
                eventType: .workshop,
                description: "Get your resume reviewed by industry professionals and practice technical interviews.",
                location: "AQ 3149",
                startTime: currentDate.addingTimeInterval(4 * 24 * 60 * 60), // 4 days
                endTime: currentDate.addingTimeInterval(4 * 24 * 60 * 60 + 2 * 60 * 60),
                attendees: generateAttendees(count: 89),
                status: .upcoming,
                tags: ["Career", "Interview Prep", "Resume Review"],
                imageURL: nil
            ),
            ClubEvent(
                id: UUID(),
                title: "Capture The Flag Competition",
                clubName: "SFU Cybersecurity Club",
                eventType: .competition,
                description: "Test your hacking skills in this beginner-friendly CTF! Learn web exploitation, cryptography, and more.",
                location: "Online (Discord)",
                startTime: currentDate.addingTimeInterval(5 * 24 * 60 * 60), // 5 days
                endTime: currentDate.addingTimeInterval(5 * 24 * 60 * 60 + 4 * 60 * 60),
                attendees: generateAttendees(count: 67),
                status: .upcoming,
                tags: ["Security", "CTF", "Hacking", "Online"],
                imageURL: nil
            ),
            ClubEvent(
                id: UUID(),
                title: "CSSS General Meeting",
                clubName: "Computer Science Student Society",
                eventType: .generalMeeting,
                description: "Monthly CSSS meeting - discuss upcoming events, vote on initiatives, and enjoy free pizza!",
                location: "CSIL (TASC 1 9200)",
                startTime: currentDate.addingTimeInterval(3 * 24 * 60 * 60), // 3 days
                endTime: currentDate.addingTimeInterval(3 * 24 * 60 * 60 + 60 * 60),
                attendees: generateAttendees(count: 134),
                status: .upcoming,
                tags: ["General Meeting", "Free Food", "Community"],
                imageURL: nil
            ),
            ClubEvent(
                id: UUID(),
                title: "AI/ML Workshop: RAG Systems",
                clubName: "SFU AI Club",
                eventType: .workshop,
                description: "Learn how to build Retrieval-Augmented Generation systems using LangChain and OpenAI.",
                location: "AQ 4140",
                startTime: currentDate.addingTimeInterval(6 * 24 * 60 * 60), // 6 days
                endTime: currentDate.addingTimeInterval(6 * 24 * 60 * 60 + 2 * 60 * 60),
                attendees: generateAttendees(count: 53),
                status: .upcoming,
                tags: ["AI", "Machine Learning", "Hands-on"],
                imageURL: nil
            ),
            
            // Ongoing Event
            ClubEvent(
                id: UUID(),
                title: "Tech Career Fair",
                clubName: "SFU Career Services",
                eventType: .networking,
                description: "Meet recruiters from top tech companies! Amazon, Microsoft, Meta, and 30+ more companies attending.",
                location: "MBC Gymnasium",
                startTime: currentDate.addingTimeInterval(-1 * 60 * 60), // Started 1 hour ago
                endTime: currentDate.addingTimeInterval(3 * 60 * 60), // Ends in 3 hours
                attendees: generateAttendees(count: 412),
                status: .ongoing,
                tags: ["Career Fair", "Networking", "Recruitment"],
                imageURL: nil
            ),
            
            // Past Events
            ClubEvent(
                id: UUID(),
                title: "Web Development Bootcamp",
                clubName: "SFU Web Dev Club",
                eventType: .workshop,
                description: "Intensive workshop covering React, Node.js, and modern web development practices.",
                location: "TASC 1 9204",
                startTime: currentDate.addingTimeInterval(-3 * 24 * 60 * 60), // 3 days ago
                endTime: currentDate.addingTimeInterval(-3 * 24 * 60 * 60 + 4 * 60 * 60),
                attendees: generateAttendees(count: 78),
                status: .completed,
                tags: ["Web Dev", "React", "Node.js"],
                imageURL: nil
            ),
            ClubEvent(
                id: UUID(),
                title: "Mock Interview Night",
                clubName: "CSSS Career Committee",
                eventType: .workshop,
                description: "Practice technical interviews with upper-year students and recent grads.",
                location: "AQ 3149",
                startTime: currentDate.addingTimeInterval(-7 * 24 * 60 * 60), // 7 days ago
                endTime: currentDate.addingTimeInterval(-7 * 24 * 60 * 60 + 3 * 60 * 60),
                attendees: generateAttendees(count: 56),
                status: .completed,
                tags: ["Interview Prep", "Career"],
                imageURL: nil
            ),
        ]
    }
    
    private func generateAttendees(count: Int) -> [ClubEvent.Attendee] {
        let emojis = ["👨‍💻", "👩‍💻", "🧑‍💻", "👨‍🎓", "👩‍🎓", "🧑‍🎓", "🤓", "😎", "🚀", "💻", "🎯", "✨", "🔥", "⚡️", "🌟"]
        let firstNames = ["Alex", "Sam", "Jordan", "Taylor", "Casey", "Morgan", "Riley", "Avery", "Quinn", "Jamie", 
                          "Drew", "Skylar", "Cameron", "Reese", "Dakota", "Blake", "Phoenix", "River", "Sage", "Charlie"]
        let lastNames = ["Chen", "Patel", "Kim", "Nguyen", "Garcia", "Singh", "Lee", "Wang", "Brown", "Martinez",
                        "Johnson", "Williams", "Davis", "Rodriguez", "Wilson", "Anderson", "Thomas", "Taylor", "Moore", "Jackson"]
        let majors = ["Computer Science", "Software Engineering", "Computing Science", "Data Science", "CS + Business",
                     "CS + Math", "Computer Engineering", "Interactive Systems", "AI/ML"]
        let years = ["1st Year", "2nd Year", "3rd Year", "4th Year", "5th Year", "Masters", "PhD"]
        let bios = [
            "Love hackathons and building cool projects!",
            "Passionate about AI and machine learning 🤖",
            "Full-stack developer | Open source contributor",
            "Competitive programmer | 3x hackathon winner",
            "Building the future, one line of code at a time",
            "Always down to collaborate on projects!",
            "Cybersecurity enthusiast | CTF player",
            "Learning in public | Tech blogger",
            "Looking to connect with fellow CS students",
            "Aspiring software engineer | Love to network"
        ]
        let leetcodeUsers = ["alex_codes", "sam_algo", "jordan_dev", "taylor_tech", nil, "morgan_cp", nil, "avery_coder", "quinn_dev", nil]
        let githubUsers = ["alexchen", "sampatel", "jordankim", nil, "caseygarcia", "morgansingh", "rileylee", nil, "quinncodes", "jamiedev"]
        let linkedinUsers = ["alexchen", "sampatel", nil, "taylornguyen", "caseygarcia", nil, "rileylee", "averywang", "quinnsmith", nil]
        
        // Create a pool of attendees with some recurring ones
        var attendeePool: [ClubEvent.Attendee] = []
        
        for i in 0..<min(count, 20) {
            let firstName = firstNames[i % firstNames.count]
            let lastName = lastNames[i % lastNames.count]
            let fullName = "\(firstName) \(lastName)"
            
            // Assign common event counts (simulate users who attend multiple events)
            let commonEvents = i < 5 ? Int.random(in: 2...5) : (i < 10 ? Int.random(in: 0...2) : 0)
            
            let attendee = ClubEvent.Attendee(
                id: UUID(),
                name: fullName,
                avatarEmoji: emojis[i % emojis.count],
                rsvpStatus: .going,
                major: majors[i % majors.count],
                year: years[i % years.count],
                bio: bios[i % bios.count],
                leetcodeUsername: leetcodeUsers[i % leetcodeUsers.count],
                githubUsername: githubUsers[i % githubUsers.count],
                linkedinUsername: linkedinUsers[i % linkedinUsers.count],
                commonEventCount: commonEvents
            )
            attendeePool.append(attendee)
        }
        
        // Sort by common events (people you've met before go first)
        return attendeePool.sorted { $0.commonEventCount > $1.commonEventCount }
    }
}
