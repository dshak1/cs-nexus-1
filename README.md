# CS Nexus - Campus CS Events Discovery App

## Overview

CS Nexus is a campus-focused app that centralizes computer science events and resources for students. Built during SFU Surge's StormHacks 2025, it addresses the challenge of scattered CS event information across multiple platforms (Instagram, LinkedIn, email, Discord, posters, etc.) by providing a unified discovery experience.

**Mission:** Help CS students discover and engage with campus events, see which friends are attending, and help organizers gauge attendance for better event planning.

## Inspiration

The app was inspired by attending SFU Surge's pre-hack resume workshop, where Ariel Tyson, Martin Wong, and Mahim Chaudhary helped reconstruct resumes. This experience highlighted the value of campus resources and the challenge of discovering them when information is scattered across different mediums.

## Core Features

### 1. Event Discovery ✅
- **Centralized Events**: All CS events in one place
- **Real-time Updates**: Live event information
- **Event Categories**: Workshops, hackathons, networking, study groups
- **Location Integration**: Campus building locations and directions

### 2. Social Features ✅
- **Friend Attendance**: See which friends are going to events
- **RSVP System**: Easy event registration
- **Event Sharing**: Share interesting events with friends
- **Attendee Profiles**: Connect with fellow CS students

### 3. Organizer Tools ✅
- **Attendance Tracking**: Gauge how many people to prepare for
- **Event Analytics**: Understand engagement patterns
- **Resource Planning**: Better preparation for events

### 4. Study & Collaboration ✅
- **Study Sessions**: Find and join study groups
- **LeetCode Integration**: Collaborative coding practice
- **Project Collaboration**: Connect with potential teammates
- **Academic Resources**: Access to CS department resources

## Technical Implementation

### Architecture
- **Platform**: iOS (SwiftUI)
- **Backend**: Real-time WebSocket connections for live updates
- **Data**: Local storage with cloud synchronization
- **Location**: Campus-specific location services

### Key Components
- **Event Management**: Centralized event creation and discovery
- **User Profiles**: CS student profiles with interests and skills
- **Social Graph**: Friend connections and event attendance
- **Calendar Integration**: Export events to personal calendars
- **Real-time Updates**: Live attendance and event changes

## Development Story

Built during StormHacks 2025:
- **Friday**: Speed-learning Swift documentation
- **Saturday**: Full day of coding and development
- **2:30 AM**: Major app recalibration (shoutout to Fady Nasr)
- **Result**: Functional app ready for campus deployment

## Features for Students

### Discovery
- Browse all CS events happening on campus
- Filter by event type, date, and location
- See event details, organizers, and requirements
- Get directions to event locations

### Social Engagement
- See which friends are attending events
- RSVP and share events with friends
- Connect with other CS students
- Build your CS network

### Study & Learning
- Join collaborative study sessions
- Practice coding with LeetCode integration
- Find project teammates
- Access academic resources

## Features for Organizers

### Event Management
- Create and manage CS events
- Track RSVPs and attendance
- Gauge interest before events
- Plan resources accordingly

### Analytics
- Understand event engagement
- Track popular event types
- Optimize event timing and location
- Build better CS community

## Technical Requirements

- **iOS 14.0+**: Modern SwiftUI framework
- **Location Services**: Campus location permissions
- **Network**: Real-time event updates
- **Storage**: Local event and user data

## Future Development Ideas

### Enhanced Social Features
- Event recommendations based on interests
- Study group matching algorithms
- CS career path guidance
- Alumni network integration

### Advanced Analytics
- Event success prediction
- Optimal event timing analysis
- Student engagement patterns
- Resource optimization

### Campus Integration
- SFU-specific features
- Integration with university systems
- Department collaboration tools
- Academic calendar sync

## Getting Started

1. **Download**: Install CS Nexus from the App Store
2. **Sign Up**: Create your CS student profile
3. **Connect**: Add friends and join the community
4. **Discover**: Browse and attend CS events
5. **Engage**: RSVP, share, and connect with peers

## Acknowledgments

- **SFU Surge Team**: For organizing StormHacks 2025
- **Resume Workshop**: Ariel Tyson, Martin Wong, Mahim Chaudhary
- **Development Support**: Fady Nasr and the entire Surge community
- **CS Community**: For inspiring better campus engagement

## Contributing

We welcome ideas and critiques for further development! The app is designed to grow with the CS community's needs.

---

**Built with**: SwiftUI, WebSocket, Core Location, EventKit
**Hackathon**: SFU Surge StormHacks 2025
**Status**: Active development for campus deployment