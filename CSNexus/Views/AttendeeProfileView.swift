//
//  AttendeeProfileView.swift
//  CSNexus
//
//  Profile view for event attendees
//  Created by GitHub Copilot on 2025-10-05.
//

import SwiftUI

struct AttendeeProfileView: View {
    let attendee: ClubEvent.Attendee
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 12) {
                        Text(attendee.avatarEmoji)
                            .font(.system(size: 80))
                            .frame(width: 120, height: 120)
                            .background(Color(.systemGray6))
                            .clipShape(Circle())
                        
                        Text(attendee.name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("\(attendee.major) • \(attendee.year)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        // Common events badge
                        if attendee.hasMetBefore {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("\(attendee.commonEventCount) event\(attendee.commonEventCount > 1 ? "s" : "") in common")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(20)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Bio
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About")
                            .font(.headline)
                        
                        Text(attendee.bio)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Coding Profiles
                    if attendee.leetcodeUsername != nil || attendee.githubUsername != nil {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Coding Profiles")
                                .font(.headline)
                            
                            if let leetcode = attendee.leetcodeUsername {
                                ProfileLinkCard(
                                    icon: "chevron.left.forwardslash.chevron.right",
                                    title: "LeetCode",
                                    username: leetcode,
                                    color: .orange,
                                    url: "https://leetcode.com/\(leetcode)"
                                )
                            }
                            
                            if let github = attendee.githubUsername {
                                ProfileLinkCard(
                                    icon: "chevron.left.forwardslash.chevron.right",
                                    title: "GitHub",
                                    username: github,
                                    color: .purple,
                                    url: "https://github.com/\(github)"
                                )
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Social Links
                    if let linkedin = attendee.linkedinUsername {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Connect")
                                .font(.headline)
                            
                            ProfileLinkCard(
                                icon: "person.badge.plus",
                                title: "LinkedIn",
                                username: linkedin,
                                color: .blue,
                                url: "https://linkedin.com/in/\(linkedin)"
                            )
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Quick Actions
                    VStack(spacing: 12) {
                        Button(action: {
                            // TODO: Send connection request
                            print("👋 Sending connection request to \(attendee.name)")
                        }) {
                            HStack {
                                Image(systemName: "person.badge.plus.fill")
                                Text("Send Connection Request")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        
                        Button(action: {
                            // TODO: Start chat
                            print("💬 Starting chat with \(attendee.name)")
                        }) {
                            HStack {
                                Image(systemName: "message.fill")
                                Text("Send Message")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray6))
                            .foregroundColor(.primary)
                            .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
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

// MARK: - Profile Link Card
struct ProfileLinkCard: View {
    let icon: String
    let title: String
    let username: String
    let color: Color
    let url: String
    
    var body: some View {
        Link(destination: URL(string: url)!) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(color)
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("@\(username)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

#Preview {
    AttendeeProfileView(
        attendee: ClubEvent.Attendee(
            id: UUID(),
            name: "Alex Chen",
            avatarEmoji: "👨‍💻",
            rsvpStatus: .going,
            major: "Computer Science",
            year: "3rd Year",
            bio: "Passionate about AI and machine learning. Love hackathons and building cool projects!",
            leetcodeUsername: "alex_codes",
            githubUsername: "alexchen",
            linkedinUsername: "alexchen",
            commonEventCount: 3
        )
    )
}
