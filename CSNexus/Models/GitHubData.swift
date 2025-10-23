//
//  GitHubData.swift
//  CSNexus
//
//  Created by GitHub Copilot on 2025-10-05.
//

import Foundation

// MARK: - GitHub Contribution Models
struct GitHubContribution: Identifiable, Codable {
    let id = UUID()
    let date: Date
    let count: Int
    
    var level: ContributionLevel {
        switch count {
        case 0: return .none
        case 1...3: return .low
        case 4...7: return .medium
        case 8...12: return .high
        default: return .veryHigh
        }
    }
    
    enum ContributionLevel {
        case none, low, medium, high, veryHigh
    }
}

struct GitHubStats: Codable {
    let username: String
    let totalContributions: Int
    let longestStreak: Int
    let currentStreak: Int
    let publicRepos: Int
    let followers: Int
    let following: Int
    let stars: Int
    
    var contributionsThisMonth: Int {
        // Mock calculation
        return Int(Double(totalContributions) * 0.15)
    }
}
