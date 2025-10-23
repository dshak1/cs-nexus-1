//
//  User.swift
//  CSNexus
//
//  Created by GitHub Copilot on 2025-10-04.
//

import Foundation

struct User: Identifiable, Codable {
    let id = UUID()
    let name: String
    let major: String
    let year: String // e.g., "2nd Year", "3rd Year", "Graduate"
    let interests: [String] // Professional interests: "AI/ML", "Web Dev", "Systems", etc.
    let school: String
    let profilePicture: String? // System icon name for now
    var eventsAttended: [UUID] // Event IDs
    var linkedin: String?
    var github: String?
    var leetcodeUsername: String?
    
    init(
        name: String,
        major: String = "Computer Science",
        year: String = "3rd Year",
        interests: [String] = [],
        school: String = "Simon Fraser University",
        profilePicture: String? = nil,
        eventsAttended: [UUID] = [],
        linkedin: String? = nil,
        github: String? = nil,
        leetcodeUsername: String? = nil
    ) {
        self.name = name
        self.major = major
        self.year = year
        self.interests = interests
        self.school = school
        self.profilePicture = profilePicture
        self.eventsAttended = eventsAttended
        self.linkedin = linkedin
        self.github = github
        self.leetcodeUsername = leetcodeUsername
    }
    
    var eventCount: Int {
        eventsAttended.count
    }
}

enum UserMode: String, CaseIterable {
    case online = "Online"
    case ghost = "Ghost"  
    case hidden = "Hidden"
    
    var description: String {
        switch self {
        case .online:
            return "Visible to others and can discover peers"
        case .ghost:
            return "Invisible but can see others"
        case .hidden:
            return "Completely offline"
        }
    }
    
    var icon: String {
        switch self {
        case .online:
            return "eye"
        case .ghost:
            return "eye.slash"
        case .hidden:
            return "minus.circle"
        }
    }
}