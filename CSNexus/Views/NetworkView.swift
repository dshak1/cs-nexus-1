//
//  NetworkView.swift
//  CSNexus
//
//  Created by GitHub Copilot on 2025-10-05.
//

import SwiftUI

struct NetworkView: View {
    @EnvironmentObject var eventManager: EventManager
    @State private var selectedConnection: Connection?
    @State private var showingProfile = false
    @State private var searchText = ""
    
    var filteredConnections: [Connection] {
        if searchText.isEmpty {
            return eventManager.connections.sorted(by: { $0.timestamp > $1.timestamp })
        } else {
            return eventManager.connections.filter {
                $0.userName.localizedCaseInsensitiveContains(searchText) ||
                $0.userMajor.localizedCaseInsensitiveContains(searchText) ||
                $0.userSchool.localizedCaseInsensitiveContains(searchText) ||
                $0.userInterests.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
            }.sorted(by: { $0.timestamp > $1.timestamp })
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Stats Summary
                statsCard
                
                // Connections List
                if filteredConnections.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredConnections) { connection in
                                ConnectionCard(connection: connection)
                                    .onTapGesture {
                                        selectedConnection = connection
                                        showingProfile = true
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("My Network")
            .searchable(text: $searchText, prompt: "Search connections")
            .sheet(isPresented: $showingProfile) {
                if let connection = selectedConnection {
                    ConnectionProfileView(connection: connection)
                }
            }
        }
    }
    
    private var statsCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                StatBadge(
                    icon: "person.3.fill",
                    value: "\(eventManager.connections.count)",
                    label: "Connections",
                    color: .blue
                )
                
                StatBadge(
                    icon: "calendar.badge.checkmark",
                    value: "\(eventManager.getTotalEventsAttended())",
                    label: "Events",
                    color: .green
                )
                
                StatBadge(
                    icon: "sparkles",
                    value: "\(eventManager.getConnectionsThisMonth())",
                    label: "This Month",
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color.blue.opacity(0.05))
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.2.badge.gearshape")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Connections Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Attend events and meet people to build your professional network")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: {
                // Navigate to events tab
            }) {
                HStack {
                    Image(systemName: "calendar.badge.plus")
                    Text("Browse Events")
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

struct StatBadge: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

struct ConnectionCard: View {
    let connection: Connection
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(connection.userName)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("\(connection.userMajor) • \(connection.userYear)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(connection.userSchool)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    if let eventType = connection.eventType {
                        Image(systemName: eventType.icon)
                            .foregroundColor(colorForType(eventType))
                    }
                    
                    Text(connection.timeAgoString)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Connection context
            if let eventName = connection.eventName {
                HStack(spacing: 6) {
                    Image(systemName: "calendar.badge.checkmark")
                        .font(.caption)
                        .foregroundColor(.green)
                    Text("Met at \(eventName)")
                        .font(.caption)
                        .foregroundColor(.green)
                        .fontWeight(.medium)
                }
                .padding(.leading, 48)
            }
            
            // Shared events
            if !connection.sharedEvents.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.caption)
                        .foregroundColor(.orange)
                    Text("Both attended \(connection.sharedEvents.count) events")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .fontWeight(.medium)
                }
                .padding(.leading, 48)
            }
            
            // Shared interests
            if !connection.sharedInterests.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(connection.sharedInterests.prefix(4), id: \.self) { interest in
                            Text(interest)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(6)
                        }
                    }
                    .padding(.leading, 48)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    private func colorForType(_ type: EventType) -> Color {
        switch type {
        case .hackathon: return .blue
        case .workshop: return .orange
        case .techTalk: return .purple
        case .careerFair: return .green
        case .networking: return .pink
        case .officeTour: return .cyan
        case .competition: return .red
        case .conference: return .indigo
        }
    }
}

struct ConnectionProfileView: View {
    let connection: Connection
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var eventManager: EventManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Profile Header
                    VStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        Text(connection.userName)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        VStack(spacing: 4) {
                            Text("\(connection.userMajor) • \(connection.userYear)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text(connection.userSchool)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    
                    // Connection Context
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Connection Details")
                            .font(.headline)
                        
                        if let eventName = connection.eventName {
                            InfoRow(
                                icon: "calendar.badge.checkmark",
                                title: "Met At",
                                value: eventName,
                                color: .green
                            )
                        }
                        
                        InfoRow(
                            icon: "clock",
                            title: "Connected",
                            value: connection.timestamp.formatted(date: .long, time: .omitted),
                            color: .blue
                        )
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                    
                    // Shared Events
                    if !connection.sharedEvents.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "calendar.badge.clock")
                                    .foregroundColor(.orange)
                                Text("Mutual Events")
                                    .font(.headline)
                            }
                            
                            ForEach(connection.sharedEvents, id: \.self) { eventName in
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.caption)
                                    Text(eventName)
                                        .font(.subheadline)
                                    Spacer()
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(12)
                    }
                    
                    // Professional Interests
                    if !connection.userInterests.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.blue)
                                Text("Professional Interests")
                                    .font(.headline)
                            }
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                                ForEach(connection.userInterests, id: \.self) { interest in
                                    Text(interest)
                                        .font(.subheadline)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(connection.sharedInterests.contains(interest) ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                                        .foregroundColor(connection.sharedInterests.contains(interest) ? .blue : .primary)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(12)
                    }
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            // Send message action
                        }) {
                            HStack {
                                Image(systemName: "message.fill")
                                Text("Send Message")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        
                        HStack(spacing: 12) {
                            Button(action: {
                                // View LinkedIn
                            }) {
                                HStack {
                                    Image(systemName: "link.circle.fill")
                                    Text("LinkedIn")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.cyan.opacity(0.2))
                                .foregroundColor(.cyan)
                                .cornerRadius(12)
                            }
                            
                            Button(action: {
                                // View GitHub
                            }) {
                                HStack {
                                    Image(systemName: "chevron.left.forwardslash.chevron.right")
                                    Text("GitHub")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.purple.opacity(0.2))
                                .foregroundColor(.purple)
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
    }
}

#Preview {
    NetworkView()
        .environmentObject(EventManager())
}
