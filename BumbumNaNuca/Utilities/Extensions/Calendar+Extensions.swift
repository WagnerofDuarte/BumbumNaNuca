//
//  Calendar+Extensions.swift
//  BumbumNaNuca
//
//  Created by AI Assistant on 09/01/26.
//

import Foundation

// MARK: - CheckIn Streak Calculation

struct CheckInStreak {
    /// Calculates the current streak from an array of check-in dates
    /// - Parameter checkIns: Array of Date objects (can be unsorted, duplicates allowed)
    /// - Returns: Current streak count (0 if no recent check-ins)
    static func calculateStreak(from checkIns: [Date]) -> Int {
        guard !checkIns.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Normalize all check-ins to start of day and remove duplicates
        let uniqueDays = Set(checkIns.map { calendar.startOfDay(for: $0) })
            .sorted(by: >) // Most recent first
        
        // Check if there's a check-in today or yesterday (streak is still active)
        guard let mostRecent = uniqueDays.first,
              let daysDiff = calendar.dateComponents([.day], from: mostRecent, to: today).day,
              daysDiff <= 1 else {
            return 0 // Streak broken
        }
        
        // Count consecutive days backwards from most recent
        var streak = 0
        var expectedDate = mostRecent
        
        for checkInDay in uniqueDays {
            if checkInDay == expectedDate {
                streak += 1
                // Move to previous day
                expectedDate = calendar.date(byAdding: .day, value: -1, to: expectedDate)!
            } else {
                break // Gap found, streak ends
            }
        }
        
        return streak
    }
    
    /// Checks if two dates are consecutive days
    /// - Returns: true if date2 is exactly 1 day after date1
    static func areConsecutiveDays(_ date1: Date, _ date2: Date) -> Bool {
        let calendar = Calendar.current
        let day1 = calendar.startOfDay(for: date1)
        let day2 = calendar.startOfDay(for: date2)
        
        guard let diff = calendar.dateComponents([.day], from: day1, to: day2).day else {
            return false
        }
        
        return abs(diff) == 1
    }
}
