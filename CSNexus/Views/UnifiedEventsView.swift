//
//  UnifiedEventsView.swift
//  CSNexus
//
//  Unified view for all events - tech networking + club events
//  Created by GitHub Copilot on 2025-10-05.
//

import SwiftUI

struct UnifiedEventsView: View {
    @EnvironmentObject var eventManager: EventManager
    @StateObject private var clubEventManager = ClubEventManager()
    @State private var selectedTab: EventTab = .upcoming
    @State private var selectedClubEvent: ClubEvent?
    @State private var selectedNetworkingEvent: Event?
    @State private var showingNetworkingEventDetail = false
    
    enum EventTab: String, CaseIterable {
        case upcoming = "Upcoming"
        case ongoing = "Live Now"
        case past = "Past"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Selector
                Picker("Event Status", selection: $selectedTab) {
                    ForEach(EventTab.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Event List
                ScrollView {
                    VStack(spacing: 16) {
                        switch selectedTab {
                        case .upcoming:
                            upcomingEventsSection
                            
                        case .ongoing:
                            ongoingEventsSection
                            
                        case .past:
                            pastEventsSection
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Events")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                clubEventManager.loadEvents()
                eventManager.generateMockEvents()
            }
            .sheet(item: $selectedClubEvent) { event in
                ClubEventDetailView(event: event, eventManager: clubEventManager)
            }
            .sheet(isPresented: $showingNetworkingEventDetail) {
                if let eventId = selectedNetworkingEvent?.id {
                    EventDetailView(eventId: eventId)
                }
            }
        }
    }
    
    // MARK: - Upcoming Events Section
    private var upcomingEventsSection: some View {
        Group {
            if clubEventManager.upcomingEvents.isEmpty && eventManager.upcomingEvents.isEmpty {
                emptyStateView(message: "No upcoming events")
            } else {
                // Club Events
                if !clubEventManager.upcomingEvents.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Club Events")
                            .font(.headline)
                            .foregroundColor(.purple)
                        
                        ForEach(clubEventManager.upcomingEvents) { event in
                            ClubEventCard(
                                event: event,
                                userRSVP: clubEventManager.getUserRSVP(for: event.id),
                                onRSVP: { status in
                                    clubEventManager.updateRSVP(eventId: event.id, status: status)
                                }
                            )
                            .onTapGesture {
                                selectedClubEvent = event
                            }
                        }
                    }
                }
                
                // Networking Events
                if !eventManager.upcomingEvents.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Networking Events")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .padding(.top, clubEventManager.upcomingEvents.isEmpty ? 0 : 20)
                        
                        ForEach(eventManager.upcomingEvents) { event in
                            EventCard(event: event, isPast: false)
                                .onTapGesture {
                                    selectedNetworkingEvent = event
                                    showingNetworkingEventDetail = true
                                }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Ongoing Events Section
    private var ongoingEventsSection: some View {
        Group {
            if clubEventManager.ongoingEvents.isEmpty {
                emptyStateView(message: "No events happening right now")
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(clubEventManager.ongoingEvents) { event in
                        ClubEventCard(
                            event: event,
                            userRSVP: clubEventManager.getUserRSVP(for: event.id),
                            onRSVP: { status in
                                clubEventManager.updateRSVP(eventId: event.id, status: status)
                            }
                        )
                        .onTapGesture {
                            selectedClubEvent = event
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Past Events Section
    private var pastEventsSection: some View {
        Group {
            if clubEventManager.pastEvents.isEmpty && eventManager.pastEvents.isEmpty {
                emptyStateView(message: "No past events")
            } else {
                // Club Events
                if !clubEventManager.pastEvents.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Club Events")
                            .font(.headline)
                            .foregroundColor(.purple)
                        
                        ForEach(clubEventManager.pastEvents) { event in
                            ClubEventCard(
                                event: event,
                                userRSVP: clubEventManager.getUserRSVP(for: event.id),
                                onRSVP: { status in
                                    clubEventManager.updateRSVP(eventId: event.id, status: status)
                                }
                            )
                            .onTapGesture {
                                selectedClubEvent = event
                            }
                        }
                    }
                }
                
                // Networking Events
                if !eventManager.pastEvents.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Networking Events")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .padding(.top, clubEventManager.pastEvents.isEmpty ? 0 : 20)
                        
                        ForEach(eventManager.pastEvents) { event in
                            EventCard(event: event, isPast: true)
                                .onTapGesture {
                                    selectedNetworkingEvent = event
                                    showingNetworkingEventDetail = true
                                }
                        }
                    }
                }
            }
        }
    }
    
    private func emptyStateView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text(message)
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
    }
}

#Preview {
    UnifiedEventsView()
        .environmentObject(EventManager())
}
