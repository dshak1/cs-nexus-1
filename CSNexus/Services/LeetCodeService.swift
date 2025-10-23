//
//  LeetCodeService.swift
//  CSNexus
//
//  Created by GitHub Copilot on 2025-10-05.
//

import Foundation
import Combine

enum LeetCodeError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case invalidResponse
    case userNotFound
}

@MainActor
class LeetCodeService: ObservableObject {
    @Published var problems: [LeetCodeProblem] = []
    @Published var userStats: LeetCodeUserStats?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let endpoint = "https://leetcode.com/graphql"
    
    // MARK: - Mock Data for Demo
    func loadMockData() {
        problems = generateMockProblems()
        userStats = generateMockUserStats()
    }
    
    private func generateMockProblems() -> [LeetCodeProblem] {
        return [
            LeetCodeProblem(
                id: "1",
                title: "Two Sum",
                titleSlug: "two-sum",
                difficulty: .easy,
                acRate: 49.2,
                topicTags: [
                    LeetCodeProblem.TopicTag(id: "array", name: "Array", slug: "array"),
                    LeetCodeProblem.TopicTag(id: "hash", name: "Hash Table", slug: "hash-table")
                ],
                isPaidOnly: false
            ),
            LeetCodeProblem(
                id: "15",
                title: "3Sum",
                titleSlug: "3sum",
                difficulty: .medium,
                acRate: 32.1,
                topicTags: [
                    LeetCodeProblem.TopicTag(id: "array", name: "Array", slug: "array"),
                    LeetCodeProblem.TopicTag(id: "two-pointers", name: "Two Pointers", slug: "two-pointers")
                ],
                isPaidOnly: false
            ),
            LeetCodeProblem(
                id: "206",
                title: "Reverse Linked List",
                titleSlug: "reverse-linked-list",
                difficulty: .easy,
                acRate: 72.4,
                topicTags: [
                    LeetCodeProblem.TopicTag(id: "linked-list", name: "Linked List", slug: "linked-list")
                ],
                isPaidOnly: false
            ),
            LeetCodeProblem(
                id: "200",
                title: "Number of Islands",
                titleSlug: "number-of-islands",
                difficulty: .medium,
                acRate: 57.3,
                topicTags: [
                    LeetCodeProblem.TopicTag(id: "dfs", name: "Depth-First Search", slug: "depth-first-search"),
                    LeetCodeProblem.TopicTag(id: "bfs", name: "Breadth-First Search", slug: "breadth-first-search")
                ],
                isPaidOnly: false
            ),
            LeetCodeProblem(
                id: "42",
                title: "Trapping Rain Water",
                titleSlug: "trapping-rain-water",
                difficulty: .hard,
                acRate: 58.9,
                topicTags: [
                    LeetCodeProblem.TopicTag(id: "array", name: "Array", slug: "array"),
                    LeetCodeProblem.TopicTag(id: "two-pointers", name: "Two Pointers", slug: "two-pointers"),
                    LeetCodeProblem.TopicTag(id: "dp", name: "Dynamic Programming", slug: "dynamic-programming")
                ],
                isPaidOnly: false
            ),
            LeetCodeProblem(
                id: "76",
                title: "Minimum Window Substring",
                titleSlug: "minimum-window-substring",
                difficulty: .hard,
                acRate: 40.2,
                topicTags: [
                    LeetCodeProblem.TopicTag(id: "hash", name: "Hash Table", slug: "hash-table"),
                    LeetCodeProblem.TopicTag(id: "string", name: "String", slug: "string"),
                    LeetCodeProblem.TopicTag(id: "sliding-window", name: "Sliding Window", slug: "sliding-window")
                ],
                isPaidOnly: false
            ),
            LeetCodeProblem(
                id: "121",
                title: "Best Time to Buy and Sell Stock",
                titleSlug: "best-time-to-buy-and-sell-stock",
                difficulty: .easy,
                acRate: 54.8,
                topicTags: [
                    LeetCodeProblem.TopicTag(id: "array", name: "Array", slug: "array"),
                    LeetCodeProblem.TopicTag(id: "dp", name: "Dynamic Programming", slug: "dynamic-programming")
                ],
                isPaidOnly: false
            ),
            LeetCodeProblem(
                id: "23",
                title: "Merge k Sorted Lists",
                titleSlug: "merge-k-sorted-lists",
                difficulty: .hard,
                acRate: 51.3,
                topicTags: [
                    LeetCodeProblem.TopicTag(id: "linked-list", name: "Linked List", slug: "linked-list"),
                    LeetCodeProblem.TopicTag(id: "heap", name: "Heap", slug: "heap")
                ],
                isPaidOnly: false
            ),
            LeetCodeProblem(
                id: "20",
                title: "Valid Parentheses",
                titleSlug: "valid-parentheses",
                difficulty: .easy,
                acRate: 40.6,
                topicTags: [
                    LeetCodeProblem.TopicTag(id: "string", name: "String", slug: "string"),
                    LeetCodeProblem.TopicTag(id: "stack", name: "Stack", slug: "stack")
                ],
                isPaidOnly: false
            ),
            LeetCodeProblem(
                id: "53",
                title: "Maximum Subarray",
                titleSlug: "maximum-subarray",
                difficulty: .medium,
                acRate: 50.1,
                topicTags: [
                    LeetCodeProblem.TopicTag(id: "array", name: "Array", slug: "array"),
                    LeetCodeProblem.TopicTag(id: "dp", name: "Dynamic Programming", slug: "dynamic-programming")
                ],
                isPaidOnly: false
            ),
            LeetCodeProblem(
                id: "84",
                title: "Largest Rectangle in Histogram",
                titleSlug: "largest-rectangle-in-histogram",
                difficulty: .hard,
                acRate: 42.7,
                topicTags: [
                    LeetCodeProblem.TopicTag(id: "array", name: "Array", slug: "array"),
                    LeetCodeProblem.TopicTag(id: "stack", name: "Stack", slug: "stack")
                ],
                isPaidOnly: false
            ),
            LeetCodeProblem(
                id: "141",
                title: "Linked List Cycle",
                titleSlug: "linked-list-cycle",
                difficulty: .easy,
                acRate: 48.3,
                topicTags: [
                    LeetCodeProblem.TopicTag(id: "linked-list", name: "Linked List", slug: "linked-list"),
                    LeetCodeProblem.TopicTag(id: "two-pointers", name: "Two Pointers", slug: "two-pointers")
                ],
                isPaidOnly: false
            ),
            LeetCodeProblem(
                id: "56",
                title: "Merge Intervals",
                titleSlug: "merge-intervals",
                difficulty: .medium,
                acRate: 46.8,
                topicTags: [
                    LeetCodeProblem.TopicTag(id: "array", name: "Array", slug: "array"),
                    LeetCodeProblem.TopicTag(id: "sorting", name: "Sorting", slug: "sorting")
                ],
                isPaidOnly: false
            ),
            LeetCodeProblem(
                id: "33",
                title: "Search in Rotated Sorted Array",
                titleSlug: "search-in-rotated-sorted-array",
                difficulty: .medium,
                acRate: 39.2,
                topicTags: [
                    LeetCodeProblem.TopicTag(id: "array", name: "Array", slug: "array"),
                    LeetCodeProblem.TopicTag(id: "binary-search", name: "Binary Search", slug: "binary-search")
                ],
                isPaidOnly: false
            ),
            LeetCodeProblem(
                id: "297",
                title: "Serialize and Deserialize Binary Tree",
                titleSlug: "serialize-and-deserialize-binary-tree",
                difficulty: .hard,
                acRate: 55.4,
                topicTags: [
                    LeetCodeProblem.TopicTag(id: "tree", name: "Tree", slug: "tree"),
                    LeetCodeProblem.TopicTag(id: "dfs", name: "Depth-First Search", slug: "depth-first-search")
                ],
                isPaidOnly: false
            ),
            LeetCodeProblem(
                id: "104",
                title: "Maximum Depth of Binary Tree",
                titleSlug: "maximum-depth-of-binary-tree",
                difficulty: .easy,
                acRate: 74.1,
                topicTags: [
                    LeetCodeProblem.TopicTag(id: "tree", name: "Tree", slug: "tree"),
                    LeetCodeProblem.TopicTag(id: "dfs", name: "Depth-First Search", slug: "depth-first-search")
                ],
                isPaidOnly: false
            ),
            LeetCodeProblem(
                id: "91",
                title: "Decode Ways",
                titleSlug: "decode-ways",
                difficulty: .medium,
                acRate: 32.9,
                topicTags: [
                    LeetCodeProblem.TopicTag(id: "string", name: "String", slug: "string"),
                    LeetCodeProblem.TopicTag(id: "dp", name: "Dynamic Programming", slug: "dynamic-programming")
                ],
                isPaidOnly: false
            ),
            LeetCodeProblem(
                id: "124",
                title: "Binary Tree Maximum Path Sum",
                titleSlug: "binary-tree-maximum-path-sum",
                difficulty: .hard,
                acRate: 39.6,
                topicTags: [
                    LeetCodeProblem.TopicTag(id: "tree", name: "Tree", slug: "tree"),
                    LeetCodeProblem.TopicTag(id: "dfs", name: "Depth-First Search", slug: "depth-first-search")
                ],
                isPaidOnly: false
            ),
            LeetCodeProblem(
                id: "125",
                title: "Valid Palindrome",
                titleSlug: "valid-palindrome",
                difficulty: .easy,
                acRate: 44.2,
                topicTags: [
                    LeetCodeProblem.TopicTag(id: "string", name: "String", slug: "string"),
                    LeetCodeProblem.TopicTag(id: "two-pointers", name: "Two Pointers", slug: "two-pointers")
                ],
                isPaidOnly: false
            ),
            LeetCodeProblem(
                id: "98",
                title: "Validate Binary Search Tree",
                titleSlug: "validate-binary-search-tree",
                difficulty: .medium,
                acRate: 32.4,
                topicTags: [
                    LeetCodeProblem.TopicTag(id: "tree", name: "Tree", slug: "tree"),
                    LeetCodeProblem.TopicTag(id: "dfs", name: "Depth-First Search", slug: "depth-first-search")
                ],
                isPaidOnly: false
            )
        ]
    }
    
    private func generateMockUserStats() -> LeetCodeUserStats {
        return LeetCodeUserStats(
            username: "you",
            totalSolved: 847,
            easySolved: 312,
            mediumSolved: 423,
            hardSolved: 112,
            ranking: 12543,
            contributionPoints: 2847,
            reputation: 1523
        )
    }
    
    // MARK: - Fetch Daily Problem (Most Recent)
    func fetchDailyProblem() async throws -> LeetCodeProblem {
        let query = """
        {
          activeDailyCodingChallengeQuestion {
            question {
              acRate
              difficulty
              frontendQuestionId: questionFrontendId
              paidOnly
              title
              titleSlug
              topicTags {
                name
                slug
              }
            }
          }
        }
        """
        
        let response: LeetCodeGraphQLResponse<DailyProblemResponse> = try await performGraphQLQuery(query: query)
        return response.data.activeDailyCodingChallengeQuestion.question.toLeetCodeProblem()
    }
    
    private struct DailyProblemResponse: Codable {
        let activeDailyCodingChallengeQuestion: ActiveDaily
        
        struct ActiveDaily: Codable {
            let question: ProblemsetResponse.Question
        }
    }
    
    // MARK: - Fetch Random Problems
    func fetchRandomProblems(limit: Int = 10, difficulty: String? = nil) async throws -> [LeetCodeProblem] {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        // LeetCode API requires filters parameter (can be empty object)
        let filtersString: String
        if let difficulty = difficulty {
            filtersString = "filters: {difficulty: \"\(difficulty)\"}"
        } else {
            filtersString = "filters: {}"
        }
        
        let query = """
        {
          problemsetQuestionList: questionList(
            categorySlug: ""
            limit: \(limit)
            skip: 0
            \(filtersString)
          ) {
            total: totalNum
            questions: data {
              acRate
              difficulty
              frontendQuestionId: questionFrontendId
              paidOnly
              title
              titleSlug
              topicTags {
                name
                slug
              }
            }
          }
        }
        """
        
        do {
            let response: LeetCodeGraphQLResponse<ProblemsetResponse> = try await performGraphQLQuery(query: query)
            let fetchedProblems = response.data.problemsetQuestionList.questions
                .filter { !$0.paidOnly } // Filter out paid-only problems
                .map { $0.toLeetCodeProblem() }
            
            problems = fetchedProblems
            return fetchedProblems
        } catch {
            errorMessage = "Failed to fetch problems: \(error.localizedDescription)"
            throw error
        }
    }
    
    // MARK: - Fetch User Stats
    func fetchUserStats(username: String) async throws -> LeetCodeUserStats {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        let query = """
        {
          matchedUser(username: "\(username)") {
            username
            profile {
              ranking
              reputation
            }
            submitStats {
              acSubmissionNum {
                difficulty
                count
              }
            }
          }
        }
        """
        
        do {
            let response: LeetCodeGraphQLResponse<UserProfileResponse> = try await performGraphQLQuery(query: query)
            
            guard let matchedUser = response.data.matchedUser else {
                throw LeetCodeError.userNotFound
            }
            
            let stats = matchedUser.toLeetCodeUserStats()
            userStats = stats
            return stats
        } catch {
            errorMessage = "Failed to fetch user stats: \(error.localizedDescription)"
            throw error
        }
    }
    
    // MARK: - Search Problems by Topic
    func searchProblemsByTopic(topic: String, limit: Int = 20) async throws -> [LeetCodeProblem] {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        let query = """
        {
          problemsetQuestionList: questionList(
            categorySlug: ""
            limit: \(limit)
            skip: 0
            filters: {tags: ["\(topic)"]}
          ) {
            total: totalNum
            questions: data {
              acRate
              difficulty
              frontendQuestionId: questionFrontendId
              paidOnly
              title
              titleSlug
              topicTags {
                name
                slug
              }
            }
          }
        }
        """
        
        do {
            let response: LeetCodeGraphQLResponse<ProblemsetResponse> = try await performGraphQLQuery(query: query)
            return response.data.problemsetQuestionList.questions
                .filter { !$0.paidOnly }
                .map { $0.toLeetCodeProblem() }
        } catch {
            errorMessage = "Failed to search problems: \(error.localizedDescription)"
            throw error
        }
    }
    
    // MARK: - Generic GraphQL Query Performer
    private func performGraphQLQuery<T: Codable>(query: String) async throws -> T {
        guard let url = URL(string: endpoint) else {
            print("❌ Invalid URL: \(endpoint)")
            throw LeetCodeError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 30
        
        let body: [String: Any] = [
            "query": query,
            "variables": [:]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            print("❌ Failed to serialize JSON body: \(error)")
            throw LeetCodeError.networkError(error)
        }
        
        print("🚀 Making request to: \(url)")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response type")
                throw LeetCodeError.invalidResponse
            }
            
            print("📡 Response status: \(httpResponse.statusCode)")
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print("❌ HTTP error: \(httpResponse.statusCode)")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response body: \(responseString)")
                }
                throw LeetCodeError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            do {
                let decoded = try decoder.decode(T.self, from: data)
                print("✅ Successfully decoded response")
                return decoded
            } catch let decodingError {
                print("❌ Decoding error: \(decodingError)")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response body (first 500 chars): \(String(responseString.prefix(500)))")
                }
                throw LeetCodeError.decodingError(decodingError)
            }
        } catch let error as LeetCodeError {
            throw error
        } catch {
            print("❌ Network error: \(error.localizedDescription)")
            throw LeetCodeError.networkError(error)
        }
    }
}
