//
//  CalendarExport.swift
//  CSNexus
//
//  Export events to iOS Calendar
//  Created by GitHub Copilot on 2025-10-05.
//

import Foundation
import EventKit

class CalendarExportManager {
    static let shared = CalendarExportManager()
    private let eventStore = EKEventStore()
    
    // Request calendar access
    func requestAccess(completion: @escaping (Bool, Error?) -> Void) {
        if #available(iOS 17.0, *) {
            eventStore.requestFullAccessToEvents { granted, error in
                completion(granted, error)
            }
        } else {
            eventStore.requestAccess(to: .event) { granted, error in
                completion(granted, error)
            }
        }
    }
    
    // Export ClubEvent to Calendar
    func exportClubEvent(_ event: ClubEvent, completion: @escaping (Bool, Error?) -> Void) {
        requestAccess { [weak self] granted, error in
            guard granted, error == nil else {
                completion(false, error)
                return
            }
            
            let calendarEvent = EKEvent(eventStore: self?.eventStore ?? EKEventStore())
            calendarEvent.title = event.title
            calendarEvent.notes = "\(event.description)\n\nOrganized by: \(event.clubName)\n\nRSVP via CS Nexus app"
            calendarEvent.location = event.location
            calendarEvent.startDate = event.startTime
            calendarEvent.endDate = event.endTime
            calendarEvent.calendar = self?.eventStore.defaultCalendarForNewEvents
            
            // Add alarm 30 minutes before
            let alarm = EKAlarm(relativeOffset: -30 * 60) // 30 minutes
            calendarEvent.addAlarm(alarm)
            
            do {
                try self?.eventStore.save(calendarEvent, span: .thisEvent)
                completion(true, nil)
            } catch {
                completion(false, error)
            }
        }
    }
    
    // Export Event (networking event) to Calendar
    func exportEvent(_ event: Event, completion: @escaping (Bool, Error?) -> Void) {
        requestAccess { [weak self] granted, error in
            guard granted, error == nil else {
                completion(false, error)
                return
            }
            
            let calendarEvent = EKEvent(eventStore: self?.eventStore ?? EKEventStore())
            calendarEvent.title = event.name
            calendarEvent.notes = "\(event.type.rawValue) event\n\nOrganized by: \(event.organization)\n\nRSVP via CS Nexus app"
            calendarEvent.location = event.location
            calendarEvent.startDate = event.date
            // Assume 2 hour duration for networking events
            calendarEvent.endDate = event.date.addingTimeInterval(2 * 60 * 60)
            calendarEvent.calendar = self?.eventStore.defaultCalendarForNewEvents
            
            // Add alarm 30 minutes before
            let alarm = EKAlarm(relativeOffset: -30 * 60)
            calendarEvent.addAlarm(alarm)
            
            do {
                try self?.eventStore.save(calendarEvent, span: .thisEvent)
                completion(true, nil)
            } catch {
                completion(false, error)
            }
        }
    }
    
    // Generate Google Calendar URL for networking Event
    func generateGoogleCalendarURLForEvent(_ event: Event) -> URL? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss"
        dateFormatter.timeZone = TimeZone.current
        
        let startDate = dateFormatter.string(from: event.date)
        let endDate = dateFormatter.string(from: event.date.addingTimeInterval(2 * 60 * 60))
        
        let title = event.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let description = "\(event.type.rawValue) event\n\nOrganized by: \(event.organization)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let location = event.location.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        let urlString = "https://calendar.google.com/calendar/render?action=TEMPLATE&text=\(title)&dates=\(startDate)/\(endDate)&details=\(description)&location=\(location)"
        
        return URL(string: urlString)
    }
    
    // Generate .ics file content (for sharing/downloading)
    func generateICSFile(for event: ClubEvent) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let startDate = dateFormatter.string(from: event.startTime)
        let endDate = dateFormatter.string(from: event.endTime)
        let timestamp = dateFormatter.string(from: Date())
        
        // Escape special characters in description
        let description = event.description.replacingOccurrences(of: "\n", with: "\\n")
        
        let icsContent = """
        BEGIN:VCALENDAR
        VERSION:2.0
        PRODID:-//CSNexus//Event Export//EN
        CALSCALE:GREGORIAN
        METHOD:PUBLISH
        BEGIN:VEVENT
        UID:\(event.id.uuidString)@csnexus.app
        DTSTAMP:\(timestamp)
        DTSTART:\(startDate)
        DTEND:\(endDate)
        SUMMARY:\(event.title)
        DESCRIPTION:\(description)\\n\\nOrganized by: \(event.clubName)\\n\\nRSVP via CS Nexus app
        LOCATION:\(event.location)
        STATUS:CONFIRMED
        SEQUENCE:0
        BEGIN:VALARM
        TRIGGER:-PT30M
        ACTION:DISPLAY
        DESCRIPTION:Event reminder
        END:VALARM
        END:VEVENT
        END:VCALENDAR
        """
        
        return icsContent
    }
    
    // Generate Google Calendar URL
    func generateGoogleCalendarURL(for event: ClubEvent) -> URL? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss"
        dateFormatter.timeZone = TimeZone.current
        
        let startDate = dateFormatter.string(from: event.startTime)
        let endDate = dateFormatter.string(from: event.endTime)
        
        let title = event.title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let description = "\(event.description)\n\nOrganized by: \(event.clubName)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let location = event.location.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        let urlString = "https://calendar.google.com/calendar/render?action=TEMPLATE&text=\(title)&dates=\(startDate)/\(endDate)&details=\(description)&location=\(location)"
        
        return URL(string: urlString)
    }
}
