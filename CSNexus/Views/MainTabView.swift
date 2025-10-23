//
//  MainTabView.swift
//  CSNexus
//
//  Created by GitHub Copilot on 2025-10-04.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var eventManager = EventManager()
    
    var body: some View {
        TabView {
            UnifiedEventsView()
                .tabItem {
                    Image(systemName: "calendar.badge.clock")
                    Text("Events")
                }
            
            EventMapView()
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("Map")
                }
            
            NavigationView {
                LeetCodeView()
            }
            .tabItem {
                Image(systemName: "chevron.left.forwardslash.chevron.right")
                Text("Code")
            }
            
            NetworkView()
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("Network")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle.fill")
                    Text("Profile")
                }
        }
        .environmentObject(eventManager)
        .onAppear {
            eventManager.generateMockConnections()
        }
    }
}