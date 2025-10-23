//
//  LeetCodeData.swift
//  CSNexus
//
//  Created by GitHub Copilot on 2025-10-05.
//

import Foundation

// MARK: - LeetCode Problem Models
struct LeetCodeProblem: Codable, Identifiable {
    let id: String
    let title: String
    let titleSlug: String
    let difficulty: Difficulty
    let acRate: Double
    let topicTags: [TopicTag]
    let isPaidOnly: Bool
    
    enum Difficulty: String, Codable {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"
    }
    
    struct TopicTag: Codable, Identifiable {
        let id: String
        let name: String
        let slug: String
    }
    
    var url: URL {
        URL(string: "https://leetcode.com/problems/\(titleSlug)/")!
    }
    
    var difficultyColor: String {
        switch difficulty {
        case .easy: return "green"
        case .medium: return "orange"
        case .hard: return "red"
        }
    }
}

// MARK: - LeetCode User Stats Models
struct LeetCodeUserStats: Codable {
    let username: String
    let totalSolved: Int
    let easySolved: Int
    let mediumSolved: Int
    let hardSolved: Int
    let ranking: Int?
    let contributionPoints: Int
    let reputation: Int
    
    var solveRate: Double {
        // Approximate total problems on LeetCode
        return Double(totalSolved) / 3000.0
    }
}

// MARK: - GraphQL Response Models
struct LeetCodeGraphQLResponse<T: Codable>: Codable {
    let data: T
}

struct ProblemsetResponse: Codable {
    let problemsetQuestionList: ProblemsetQuestionList
    
    struct ProblemsetQuestionList: Codable {
        let total: Int
        let questions: [Question]
    }
    
    struct Question: Codable {
        let acRate: Double
        let difficulty: String
        let frontendQuestionId: String
        let paidOnly: Bool
        let title: String
        let titleSlug: String
        let topicTags: [TopicTag]
        
        struct TopicTag: Codable {
            let name: String
            let slug: String
        }
        
        func toLeetCodeProblem() -> LeetCodeProblem {
            LeetCodeProblem(
                id: frontendQuestionId,
                title: title,
                titleSlug: titleSlug,
                difficulty: LeetCodeProblem.Difficulty(rawValue: difficulty) ?? .medium,
                acRate: acRate,
                topicTags: topicTags.map { tag in
                    LeetCodeProblem.TopicTag(
                        id: tag.slug,
                        name: tag.name,
                        slug: tag.slug
                    )
                },
                isPaidOnly: paidOnly
            )
        }
    }
}

struct UserProfileResponse: Codable {
    let matchedUser: MatchedUser?
    
    struct MatchedUser: Codable {
        let username: String
        let profile: Profile
        let submitStats: SubmitStats
        
        struct Profile: Codable {
            let ranking: Int
            let reputation: Int
        }
        
        struct SubmitStats: Codable {
            let acSubmissionNum: [SubmissionCount]
            
            struct SubmissionCount: Codable {
                let difficulty: String
                let count: Int
            }
        }
        
        func toLeetCodeUserStats() -> LeetCodeUserStats {
            let solvedCounts = Dictionary(uniqueKeysWithValues: submitStats.acSubmissionNum.map { ($0.difficulty, $0.count) })
            
            return LeetCodeUserStats(
                username: username,
                totalSolved: solvedCounts["All"] ?? 0,
                easySolved: solvedCounts["Easy"] ?? 0,
                mediumSolved: solvedCounts["Medium"] ?? 0,
                hardSolved: solvedCounts["Hard"] ?? 0,
                ranking: profile.ranking,
                contributionPoints: 0, // Not in this query
                reputation: profile.reputation
            )
        }
    }
}
