//
//  ProfileView.swift
//  CSNexus
//
//  Created by GitHub Copilot on 2025-10-05.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var eventManager: EventManager
    @State private var name = "Your Name"
    @State private var major = "Computer Science"
    @State private var year = "3rd Year"
    @State private var school = "Simon Fraser University"
    @State private var linkedin = "linkedin.com/in/yourprofile"
    @State private var github = "github.com/yourusername"
    @State private var selectedInterests: Set<String> = ["iOS Development", "AI/ML", "Web Dev"]
    @State private var showingEditProfile = false
    
    let professionalInterests = [
        "iOS Development", "AI/ML", "Web Dev", "Backend", "Frontend",
        "Cloud Computing", "Mobile Apps", "Systems", "Data Science",
        "DevOps", "Security", "Blockchain", "AR/VR", "Game Dev"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        Text(name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        VStack(spacing: 4) {
                            Text("\(major) • \(year)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text(school)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Button(action: {
                            showingEditProfile = true
                        }) {
                            Text("Edit Profile")
                                .font(.subheadline)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(20)
                        }
                    }
                    .padding(.vertical, 20)
                    
                    // Stats Grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                        ProfileStatCard(
                            icon: "calendar.badge.checkmark",
                            value: "\(eventManager.getTotalEventsAttended())",
                            label: "Events Attended",
                            color: .blue
                        )
                        
                        ProfileStatCard(
                            icon: "person.3.fill",
                            value: "\(eventManager.connections.count)",
                            label: "Connections",
                            color: .green
                        )
                        
                        ProfileStatCard(
                            icon: "calendar.badge.plus",
                            value: "\(eventManager.getUpcomingEventsRegistered())",
                            label: "Upcoming Events",
                            color: .orange
                        )
                        
                        ProfileStatCard(
                            icon: "sparkles",
                            value: "\(eventManager.getConnectionsThisMonth())",
                            label: "This Month",
                            color: .purple
                        )
                    }
                    .padding(.horizontal)
                    
                    // Professional Interests
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.blue)
                            Text("Professional Interests")
                                .font(.headline)
                        }
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                            ForEach(Array(selectedInterests), id: \.self) { interest in
                                Text(interest)
                                    .font(.subheadline)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Social Links
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "link.circle.fill")
                                .foregroundColor(.blue)
                            Text("Professional Links")
                                .font(.headline)
                        }
                        
                        SocialLinkRow(icon: "link.circle", platform: "LinkedIn", username: linkedin, color: .cyan)
                        SocialLinkRow(icon: "chevron.left.forwardslash.chevron.right", platform: "GitHub", username: github, color: .purple)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Event History
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "calendar.badge.clock")
                                .foregroundColor(.orange)
                            Text("Recent Events")
                                .font(.headline)
                        }
                        
                        if eventManager.pastEvents.filter({ $0.hasAttended }).isEmpty {
                            Text("No events attended yet")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.vertical, 8)
                        } else {
                            ForEach(eventManager.pastEvents.filter { $0.hasAttended }.prefix(5)) { event in
                                HStack {
                                    Image(systemName: event.type.icon)
                                        .foregroundColor(colorForType(event.type))
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(event.name)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        Text(event.date, style: .date)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.caption)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Export Resume Button
                    Button(action: {
                        // Export event resume
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Export Event Résumé")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Development Tools
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "hammer.fill")
                                .foregroundColor(.orange)
                            Text("Development Tools")
                                .font(.headline)
                        }
                        
                        Button(action: {
                            eventManager.generateMockConnections()
                        }) {
                            HStack {
                                Image(systemName: "person.badge.plus")
                                Text("Generate Mock Connections")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green.opacity(0.2))
                            .foregroundColor(.green)
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    Spacer(minLength: 40)
                }
                .padding(.vertical)
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView(
                    name: $name,
                    major: $major,
                    year: $year,
                    school: $school,
                    linkedin: $linkedin,
                    github: $github,
                    selectedInterests: $selectedInterests,
                    allInterests: professionalInterests
                )
            }
        }
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

struct ProfileStatCard: View {
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
                .font(.title)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

struct SocialLinkRow: View {
    let icon: String
    let platform: String
    let username: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(platform)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(username)
                    .font(.subheadline)
            }
            
            Spacer()
            
            Image(systemName: "arrow.up.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var name: String
    @Binding var major: String
    @Binding var year: String
    @Binding var school: String
    @Binding var linkedin: String
    @Binding var github: String
    @Binding var selectedInterests: Set<String>
    let allInterests: [String]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Personal Information") {
                    TextField("Name", text: $name)
                    TextField("Major", text: $major)
                    TextField("Year", text: $year)
                    TextField("School", text: $school)
                }
                
                Section("Professional Links") {
                    TextField("LinkedIn", text: $linkedin)
                        .textInputAutocapitalization(.never)
                    TextField("GitHub", text: $github)
                        .textInputAutocapitalization(.never)
                }
                
                Section("Professional Interests") {
                    ForEach(allInterests, id: \.self) { interest in
                        Button(action: {
                            if selectedInterests.contains(interest) {
                                selectedInterests.remove(interest)
                            } else {
                                selectedInterests.insert(interest)
                            }
                        }) {
                            HStack {
                                Text(interest)
                                    .foregroundColor(.primary)
                                Spacer()
                                if selectedInterests.contains(interest) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(EventManager())
}
