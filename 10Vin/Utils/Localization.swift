//
//  Localization.swift
//  10Vin
//
//  Created by Pierre ROBERT on 16/01/2026.
//

import Foundation

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}

extension Date {
    /// Formate la date en temps relatif de manière statique (ne se met pas à jour automatiquement)
    var relativeTimeString: String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.second, .minute, .hour, .day, .weekOfYear, .month, .year], from: self, to: now)
        
        if let year = components.year, year > 0 {
            if year == 1 {
                return "time.relative.years".localized.replacingOccurrences(of: "%d", with: "1").replacingOccurrences(of: "(s)", with: "")
            }
            return "time.relative.years".localized.replacingOccurrences(of: "%d", with: "\(year)")
        }
        
        if let month = components.month, month > 0 {
            if month == 1 {
                return "time.relative.months".localized.replacingOccurrences(of: "%d", with: "1").replacingOccurrences(of: "(s)", with: "")
            }
            return "time.relative.months".localized.replacingOccurrences(of: "%d", with: "\(month)").replacingOccurrences(of: "(s)", with: "")
        }
        
        if let week = components.weekOfYear, week > 0 {
            if week == 1 {
                return "time.relative.weeks".localized.replacingOccurrences(of: "%d", with: "1").replacingOccurrences(of: "(s)", with: "")
            }
            return "time.relative.weeks".localized.replacingOccurrences(of: "%d", with: "\(week)")
        }
        
        if let day = components.day, day > 0 {
            if day == 1 {
                return "time.relative.days".localized.replacingOccurrences(of: "%d", with: "1").replacingOccurrences(of: "(s)", with: "")
            }
            return "time.relative.days".localized.replacingOccurrences(of: "%d", with: "\(day)")
        }
        
        if let hour = components.hour, hour > 0 {
            if hour == 1 {
                return "time.relative.hours".localized.replacingOccurrences(of: "%d", with: "1").replacingOccurrences(of: "(s)", with: "")
            }
            return "time.relative.hours".localized.replacingOccurrences(of: "%d", with: "\(hour)")
        }
        
        if let minute = components.minute, minute > 0 {
            if minute == 1 {
                return "time.relative.minutes".localized.replacingOccurrences(of: "%d", with: "1").replacingOccurrences(of: "(s)", with: "")
            }
            return "time.relative.minutes".localized.replacingOccurrences(of: "%d", with: "\(minute)")
        }
        
        if let second = components.second, second > 5 {
            if second == 1 {
                return "time.relative.seconds".localized.replacingOccurrences(of: "%d", with: "1").replacingOccurrences(of: "(s)", with: "")
            }
            return "time.relative.seconds".localized.replacingOccurrences(of: "%d", with: "\(second)")
        }
        
        return "time.relative.justNow".localized
    }
}
