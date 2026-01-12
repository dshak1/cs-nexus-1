 CS Nexus - Campus CS Events Discovery App
 ## Tech Stack


![Swift](https://img.shields.io/badge/Swift-FA7343?style=for-the-badge&logo=swift&logoColor=white)
![SwiftUI](https://img.shields.io/badge/SwiftUI-0066CC?style=for-the-badge&logo=swift&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=apple&logoColor=white)
![WebSocket](https://img.shields.io/badge/WebSocket-010101?style=for-the-badge&logo=socketdotio&logoColor=white)
![Cloud](https://img.shields.io/badge/Cloud_Sync-4285F4?style=for-the-badge&logo=icloud&logoColor=white)

![app demo](./appdemo.png)


Overview

CS Nexus is a campus-focused app that centralizes computer science events and resources for students. Built during SFU Surge's StormHacks 2025, it addresses the challenge of scattered CS event information across multiple platforms (Instagram, LinkedIn, email, Discord, posters, etc.) by providing a unified discovery experience.

Mission: Help CS students discover and engage with campus events, see which friends are attending, and help organizers gauge attendance for better event planning.

Inspiration

The app was inspired by attending SFU Surge's pre-hack resume workshop, where the value of on campus events became apparent when I got the chance to sit with my upperclassmen and reconstruct my resume from scratch, receiving feedback from people with experience, knowledge and a desire to share it. I the CS community at SFU can greatly benefit from staying up to date with all of the best campus events.

Core Features

1. Event Discovery 
- **Centralized Events**: All CS events in one place
- **Real-time Updates**: Live event information
- **Event Categories**: Workshops, hackathons, networking, study groups
- **Location Integration**: Campus building locations and directions

Social Features 
- Friend Attendance**: See which friends are going to events
- RSVP System**: Easy event registration
- Event Sharing**: Share interesting events with friends
- Attendee Profiles**: Connect with fellow CS students

3. Organizer Tools 
- Attendance Tracking**: Gauge how many people to prepare for
- Event Analytics**: Understand engagement patterns
- Resource Planning**: Better preparation for events

4. Study & Collaboration 
- Study Sessions**: Find and join study groups
- LeetCode Integration**: Collaborative coding practice
- Project Collaboration**: Connect with potential teammates
- Academic Resources**: Access to CS department resources

Technical Implementation

Architecture
- Platform: iOS (SwiftUI)
- Backend: Real-time WebSocket connections for live updates
- Data: Local storage with cloud synchronization
- Location: Campus-specific location services

Key Components
- Event Management: Centralized event creation and discovery
- User Profiles: CS student profiles with interests and skills
- Social Graph: Friend connections and event attendance
- Calendar Integration: Export events to personal calendars
- Real-time Updates: Live attendance and event changes

Development Story

Built during StormHacks 2025:
- Friday: Speed-learning Swift documentation
- Saturday: Full day of coding and development
- 2:30 AM: Major app recalibration (shoutout to Fady Nasr)
- Result: Functional app ready for campus deployment

Features for Students

Discovery
- Browse all CS events happening on campus
- Filter by event type, date, and location
- See event details, organizers, and requirements
- Get directions to event locations
Social Engagement
- See which friends are attending events
- RSVP and share events with friends
- Connect with other CS students
- Build your CS network


features for Org

Event Management
- Create and manage CS events
- Track RSVPs and attendance
- Gauge interest before events
- Plan resources accordingly

analytics
- Understand event engagement
- Track popular event types
- Optimize event timing and location
- Build better CS community



Future dev Ideas

Enhanced Social Features
- Event recommendations based on interests
- Study group matching algorithms
- CS career path guidance
- Alumni network integration

Advanced Analytics
- Event success prediction
- Optimal event timing analysis
- Student engagement patterns
- Resource optimization

Campus Integration
- SFU-specific features
- Integration with university systems
- Department collaboration tools
- Academic calendar sync



NEXT FEATURE:
LET PEOPLE ON THE APP BE ABLE TO SCAN A QR CODE OR MANUALLY ADD EVENTS, which can maybe go through verification pipeline cuz we cant just let ppl spam it right or put bad events
