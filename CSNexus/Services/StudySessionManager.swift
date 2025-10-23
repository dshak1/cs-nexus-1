//
//  StudySessionManager.swift
//  CSNexus
//
//  Real-time collaborative study sessions using WebSocket
//  Created by GitHub Copilot on 2025-10-05.
//

import Foundation
import Combine

// MARK: - Study Session Models
struct StudySession: Identifiable, Codable {
    let id: UUID
    let title: String
    let topic: String
    let creatorId: UUID
    let creatorName: String
    let startTime: Date
    var participants: [Participant]
    var status: SessionStatus
    var problemsToSolve: [String] // LeetCode problem IDs
    var currentProblemIndex: Int
    
    enum SessionStatus: String, Codable {
        case waiting, active, paused, completed
    }
    
    struct Participant: Identifiable, Codable {
        let id: UUID
        let name: String
        var isActive: Bool
        var problemsSolved: Int
        var lastSeen: Date
    }
}

struct SessionMessage: Identifiable, Codable {
    let id: UUID
    let sessionId: UUID
    let senderId: UUID
    let senderName: String
    let content: String
    let timestamp: Date
    let type: MessageType
    
    enum MessageType: String, Codable {
        case chat, problemSolved, hint, question, celebration
    }
}

// MARK: - WebSocket Message Protocol
struct WebSocketMessage: Codable {
    let action: Action
    let payload: Data
    
    enum Action: String, Codable {
        case join, leave, chat, solveProblem, requestHint, syncState
    }
}

// MARK: - Study Session Manager
@MainActor
class StudySessionManager: NSObject, ObservableObject {
    @Published var activeSessions: [StudySession] = []
    @Published var currentSession: StudySession?
    @Published var messages: [SessionMessage] = []
    @Published var isConnected = false
    @Published var connectionError: String?
    
    private var webSocketTask: URLSessionWebSocketTask?
    private var pingTimer: Timer?
    
    // MARK: - WebSocket Connection
    func connect(to sessionId: UUID) {
        guard let url = URL(string: "wss://study-sessions.csnexus.dev/\(sessionId.uuidString)") else {
            connectionError = "Invalid WebSocket URL"
            return
        }
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        
        receiveMessage()
        startPing()
        
        print("🔌 Connecting to study session: \(sessionId)")
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        pingTimer?.invalidate()
        isConnected = false
        print("🔌 Disconnected from study session")
    }
    
    // MARK: - Send Messages
    func sendMessage(_ message: SessionMessage) {
        guard let webSocketTask = webSocketTask else { return }
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(message)
            
            let wsMessage = URLSessionWebSocketTask.Message.data(data)
            webSocketTask.send(wsMessage) { error in
                if let error = error {
                    print("❌ Failed to send message: \(error)")
                }
            }
        } catch {
            print("❌ Failed to encode message: \(error)")
        }
    }
    
    func sendProblemSolved(problemId: String) {
        guard let session = currentSession else { return }
        
        let message = SessionMessage(
            id: UUID(),
            sessionId: session.id,
            senderId: UUID(), // Current user ID
            senderName: "You",
            content: "Solved problem #\(problemId)! 🎉",
            timestamp: Date(),
            type: .problemSolved
        )
        
        sendMessage(message)
    }
    
    // MARK: - Receive Messages
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let message):
                Task { @MainActor in
                    self.handleWebSocketMessage(message)
                    self.receiveMessage() // Continue receiving
                }
                
            case .failure(let error):
                Task { @MainActor in
                    self.connectionError = "Connection lost: \(error.localizedDescription)"
                    self.isConnected = false
                }
            }
        }
    }
    
    private func handleWebSocketMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .data(let data):
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let sessionMessage = try decoder.decode(SessionMessage.self, from: data)
                messages.append(sessionMessage)
                print("📨 Received message: \(sessionMessage.content)")
            } catch {
                print("❌ Failed to decode message: \(error)")
            }
            
        case .string(let text):
            print("📨 Received text: \(text)")
            
        @unknown default:
            break
        }
    }
    
    // MARK: - Keep-Alive Ping
    private func startPing() {
        pingTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.sendPing()
        }
    }
    
    private func sendPing() {
        webSocketTask?.sendPing { error in
            if let error = error {
                print("❌ Ping failed: \(error)")
            }
        }
    }
    
    // MARK: - Mock Data (for demo without backend)
    func loadMockSessions() {
        let now = Date()
        activeSessions = [
            StudySession(
                id: UUID(),
                title: "LeetCode Daily Grind",
                topic: "Arrays & Hash Tables",
                creatorId: UUID(),
                creatorName: "Sarah Chen",
                startTime: now.addingTimeInterval(-1800),
                participants: [
                    StudySession.Participant(id: UUID(), name: "Sarah Chen", isActive: true, problemsSolved: 3, lastSeen: now),
                    StudySession.Participant(id: UUID(), name: "Mike Ross", isActive: true, problemsSolved: 2, lastSeen: now.addingTimeInterval(-120)),
                    StudySession.Participant(id: UUID(), name: "You", isActive: true, problemsSolved: 2, lastSeen: now)
                ],
                status: .active,
                problemsToSolve: ["1", "15", "200", "42", "76"],
                currentProblemIndex: 2
            ),
            StudySession(
                id: UUID(),
                title: "Dynamic Programming Deep Dive",
                topic: "DP",
                creatorId: UUID(),
                creatorName: "Alex Kim",
                startTime: now.addingTimeInterval(3600),
                participants: [
                    StudySession.Participant(id: UUID(), name: "Alex Kim", isActive: false, problemsSolved: 0, lastSeen: now),
                    StudySession.Participant(id: UUID(), name: "Priya Patel", isActive: false, problemsSolved: 0, lastSeen: now)
                ],
                status: .waiting,
                problemsToSolve: ["53", "91", "124"],
                currentProblemIndex: 0
            ),
            StudySession(
                id: UUID(),
                title: "Graph Algorithms Study Group",
                topic: "Graphs, DFS, BFS",
                creatorId: UUID(),
                creatorName: "Jordan Lee",
                startTime: now.addingTimeInterval(-900),
                participants: [
                    StudySession.Participant(id: UUID(), name: "Jordan Lee", isActive: true, problemsSolved: 1, lastSeen: now),
                    StudySession.Participant(id: UUID(), name: "Emma Wilson", isActive: true, problemsSolved: 1, lastSeen: now.addingTimeInterval(-60)),
                    StudySession.Participant(id: UUID(), name: "Chris Taylor", isActive: true, problemsSolved: 1, lastSeen: now.addingTimeInterval(-30)),
                    StudySession.Participant(id: UUID(), name: "You", isActive: true, problemsSolved: 0, lastSeen: now)
                ],
                status: .active,
                problemsToSolve: ["200", "133", "207"],
                currentProblemIndex: 0
            )
        ]
        
        // Mock messages
        messages = [
            SessionMessage(id: UUID(), sessionId: activeSessions[0].id, senderId: UUID(), senderName: "Sarah Chen", content: "Just finished Two Sum! Moving to next one.", timestamp: now.addingTimeInterval(-600), type: .problemSolved),
            SessionMessage(id: UUID(), sessionId: activeSessions[0].id, senderId: UUID(), senderName: "Mike Ross", content: "Anyone want to pair on 3Sum?", timestamp: now.addingTimeInterval(-480), type: .chat),
            SessionMessage(id: UUID(), sessionId: activeSessions[0].id, senderId: UUID(), senderName: "Sarah Chen", content: "I'm down! Let me finish this one first.", timestamp: now.addingTimeInterval(-420), type: .chat),
            SessionMessage(id: UUID(), sessionId: activeSessions[0].id, senderId: UUID(), senderName: "Mike Ross", content: "Solved 3Sum! The two-pointer approach really helped 🎉", timestamp: now.addingTimeInterval(-180), type: .problemSolved)
        ]
    }
}

// MARK: - URLSessionWebSocketDelegate
extension StudySessionManager: URLSessionWebSocketDelegate {
    nonisolated func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        Task { @MainActor in
            self.isConnected = true
            print("✅ WebSocket connected")
        }
    }
    
    nonisolated func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        Task { @MainActor in
            self.isConnected = false
            print("🔌 WebSocket closed: \(closeCode)")
        }
    }
}
