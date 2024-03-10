//
//  FoundationExtensions.swift
//  TeamWorkOrganiztion
//
//  Created by User on 2023-11-14.
//

import Foundation

//MARK: - Constants
private enum Constants {
    
    //MARK: Static
    static let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    static let emailPredFormat = "SELF MATCHES %@"
    
    static let monthDateFormat = "MMMM d, yyyy"
}

//MARK: - Fast Calendar methods
extension Calendar {
    
    //MARK: Static
    static let iso8601 = Calendar(identifier: .iso8601)
}


//MARK: - Fast String methods
public extension String {
    
    //MARK: Public
    func transformDepartmentKey() -> String {
        let components = self.components(separatedBy: "_")
        var transformedString = ""
        
        for component in components {
            let capitalizedComponent = component.prefix(1).uppercased() + component.dropFirst()
            transformedString += capitalizedComponent + " "
        }
        
        return transformedString.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Checks if the string represents a valid email address.
    ///
    /// - Returns: A Boolean value indicating whether the string is a valid email address.
    func isValidEmail() -> Bool {
        let emailRegEx = Constants.emailRegEx
        let emailPred = NSPredicate(format: Constants.emailPredFormat, emailRegEx)
        return emailPred.evaluate(with: self)
    }
    
    /// Converts the string into a Date object in the day-month format.
    ///
    /// - Returns: A Date object representing the day and month extracted from the string, or nil if conversion fails.
    func dayMonth() -> Date! {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.monthDateFormat
        if let date = dateFormatter.date(from: self) {
            return date
        } else {
            return nil
        }
    }
}


//MARK: - Fast Date methods
public extension Date {
    
    //MARK: Static
    /// Counts the number of weekdays between two dates.
    ///
    /// - Parameters:
    ///   - start: The starting date.
    ///   - end: The ending date.
    /// - Returns: The count of weekdays between the two dates.
    static func coutWeekdays(from start: Date, to end: Date) -> Int {
        guard start < end else { return 0 }
        var weekendDays = 0
        var workingDays = 0
        var date = start.noon
        repeat {
            if date.isDateInWeekend {
                weekendDays += 1
            } else {
                workingDays += 1
            }
            date = date.tomorrow
        } while date < end
        return workingDays
    }
    
    /// Retrieves the date one day before the provided date.
    ///
    /// - Parameter date: The reference date.
    /// - Returns: The date one day before the reference date.
    static func dateOneDayBefore(_ date: Date) -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: -1, to: date)!
    }
    
    static func convertDateString(_ dateString: String) -> String? {
        let originalFormatter = DateFormatter()
        originalFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"

        if let date = originalFormatter.date(from: dateString) {
            let resultFormatter = DateFormatter()
            resultFormatter.dateFormat = "EEEE, MMMM d"
            let result = resultFormatter.string(from: date)
            return result
        } else {
            return nil
        }
    }
    
    static func convertCheckedOutDateString(_ dateString: String) -> String? {
        let originalFormatter = DateFormatter()
        originalFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

        if let date = originalFormatter.date(from: dateString) {
            let resultFormatter = DateFormatter()
            resultFormatter.dateFormat = "EEEE, MMMM d"
            let result = resultFormatter.string(from: date)
            return result
        } else {
            return nil
        }
    }
    
    
    //MARK: Public
    /// Checks if the date falls on a weekend.
    var isDateInWeekend: Bool {
        return Calendar.iso8601.isDateInWeekend(self)
    }
    
    /// Retrieves the date of the next day.
    var tomorrow: Date {
        return Calendar.iso8601.date(byAdding: .day, value: 1, to: noon)!
    }
    
    /// Retrieves the date at noon of the current date.
    var noon: Date {
        return Calendar.iso8601.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    
    /// Retrieves the day and month as a string.
    ///
    /// - Returns: The formatted string of the day and month.
    func dayMonth() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.monthDateFormat
        let dateString = dateFormatter.string(from: self)
        return dateString
    }
}
