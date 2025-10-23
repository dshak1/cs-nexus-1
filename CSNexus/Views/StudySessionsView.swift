//
//  StudySessionsView.swift
//  CSNexus
//
//  Real-time collaborative study sessions
//  Created by GitHub Copilot on 2025-10-05.
//

import SwiftUI

struct StudySessionsView: View {
    @StateObject private var sessionManager = StudySessionManager()
    @State private var showingCreateSession = false
    @State private var selectedSession: StudySession?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Stats
                    statsHeader
                    
                    // Active Sessions
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Live Study Sessions")
                                .font(.title2)
                                .fontWeight(.bold)
                            Spacer()
                            Image(systemName: "antenna.radiowaves.left.and.right")
                                .foregroundColor(.green)
                                .symbolEffect(.pulse)
                        }
                        
                        if sessionManager.activeSessions.isEmpty {
                            emptyStateView
                        } else {
                            ForEach(sessionManager.activeSessions) { session in
                                SessionCard(session: session)
                                    .onTapGesture {
                                        selectedSession = session
                                    }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Study Together")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreateSession = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .onAppear {
                sessionManager.loadMockSessions()
            }
            .sheet(isPresented: $showingCreateSession) {
                CreateSessionView()
            }
            .sheet(item: $selectedSession) { session in
                SessionDetailView(session: session, manager: sessionManager)
            }
        }
    }
    
    private var statsHeader: some View {
        HStack(spacing: 16) {
            StatCard(
                icon: "person.3.fill",
                value: "\(sessionManager.activeSessions.reduce(0) { $0 + $1.participants.count })",
                label: "Active Users",
                color: .blue
            )
            StatCard(
                icon: "flame.fill",
                value: "\(sessionManager.activeSessions.filter { $0.status == .active }.count)",
                label: "Live Sessions",
                color: .orange
            )
            StatCard(
                icon: "checkmark.circle.fill",
                value: "127",
                label: "Solved Today",
                color: .green
            )
        }
        .padding()
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2.wave.2")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("No active sessions")
                .font(.headline)
            Text("Create one to start studying with others!")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Button("Create Session") {
                showingCreateSession = true
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
    }
}

// MARK: - Session Card
struct SessionCard: View {
    let session: StudySession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.title)
                        .font(.headline)
                    Text("by \(session.creatorName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                StatusBadge(status: session.status)
            }
            
            // Topic
            HStack {
                Image(systemName: "book.fill")
                    .font(.caption)
                Text(session.topic)
                    .font(.subheadline)
            }
            .foregroundColor(.blue)
            
            // Progress
            HStack {
                ProgressView(value: Double(session.currentProblemIndex), total: Double(session.problemsToSolve.count))
                    .tint(.green)
                Text("\(session.currentProblemIndex)/\(session.problemsToSolve.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Participants
            HStack {
                ForEach(session.participants.prefix(5)) { participant in
                    Circle()
                        .fill(participant.isActive ? Color.green : Color.gray)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Text(participant.name.prefix(1))
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        )
                }
                if session.participants.count > 5 {
                    Text("+\(session.participants.count - 5)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(timeString(from: session.startTime))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(session.status == .active ? Color.green : Color.clear, lineWidth: 2)
        )
    }
    
    private func timeString(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 0 {
            return "Starts in \(Int(-interval / 60))m"
        } else if interval < 3600 {
            return "\(Int(interval / 60))m ago"
        } else {
            return "\(Int(interval / 3600))h ago"
        }
    }
}

// MARK: - Status Badge
struct StatusBadge: View {
    let status: StudySession.SessionStatus
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            Text(status.rawValue.capitalized)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(statusColor.opacity(0.2))
        .cornerRadius(8)
    }
    
    private var statusColor: Color {
        switch status {
        case .waiting: return .orange
        case .active: return .green
        case .paused: return .yellow
        case .completed: return .gray
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Session Detail View
struct SessionDetailView: View {
    let session: StudySession
    @ObservedObject var manager: StudySessionManager
    @Environment(\.dismiss) var dismiss
    @State private var messageText = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Participants header
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(session.participants) { participant in
                            VStack(spacing: 4) {
                                Circle()
                                    .fill(participant.isActive ? Color.green : Color.gray)
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Text(participant.name.prefix(1))
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                    )
                                Text(participant.name.split(separator: " ").first ?? "")
                                    .font(.caption)
                                    .lineLimit(1)
                                Text("\(participant.problemsSolved) solved")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                }
                .background(Color(.systemGray6))
                
                Divider()
                
                // Messages
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(manager.messages.filter { $0.sessionId == session.id }) { message in
                            MessageBubble(message: message)
                        }
                    }
                    .padding()
                }
                
                Divider()
                
                // Input
                HStack {
                    TextField("Send a message...", text: $messageText)
                        .textFieldStyle(.roundedBorder)
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(messageText.isEmpty ? Color.gray : Color.blue)
                            .clipShape(Circle())
                    }
                    .disabled(messageText.isEmpty)
                }
                .padding()
            }
            .navigationTitle(session.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Leave") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        manager.sendProblemSolved(problemId: "123")
                    }) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
            }
        }
    }
    
    private func sendMessage() {
        let message = SessionMessage(
            id: UUID(),
            sessionId: session.id,
            senderId: UUID(),
            senderName: "You",
            content: messageText,
            timestamp: Date(),
            type: .chat
        )
        manager.sendMessage(message)
        messageText = ""
    }
}

// MARK: - Message Bubble
struct MessageBubble: View {
    let message: SessionMessage
    
    var body: some View {
        HStack {
            if message.senderName == "You" {
                Spacer()
            }
            
            VStack(alignment: message.senderName == "You" ? .trailing : .leading, spacing: 4) {
                if message.senderName != "You" {
                    Text(message.senderName)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    if message.type == .problemSolved {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                    Text(message.content)
                }
                .padding(12)
                .background(message.senderName == "You" ? Color.blue : Color(.systemGray5))
                .foregroundColor(message.senderName == "You" ? .white : .primary)
                .cornerRadius(16)
                
                Text(timeString(from: message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if message.senderName != "You" {
                Spacer()
            }
        }
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Create Session View
struct CreateSessionView: View {
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var topic = ""
    @State private var selectedProblems: [String] = []
    
    var body: some View {
        NavigationView {
            Form {
                Section("Session Details") {
                    TextField("Title", text: $title)
                    TextField("Topic (e.g., Arrays, DP)", text: $topic)
                }
                
                Section("Problems") {
                    Text("Select 3-5 LeetCode problems to solve together")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("New Study Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        // Create session logic
                        dismiss()
                    }
                    .disabled(title.isEmpty || topic.isEmpty)
                }
            }
        }
    }
}

#Preview {
    StudySessionsView()
}
