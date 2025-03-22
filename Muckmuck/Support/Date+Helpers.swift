//
//  Date+Helpers.swift
//  Muckmuck
//
//  Created by 임영택 on 3/22/25.
//

import Foundation

extension Date {
    func isToday() -> Bool {
        Calendar.current.isDateInToday(self)
    }
    
    var dayString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM월 dd일"
        return dateFormatter.string(from: self)
    }
    
    var timeString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "a h시 mm분"
        return dateFormatter.string(from: self)
    }
    
    var localizedString: String {
        if isToday() {
            return timeString
        }
        
        return "\(dayString) \(timeString)"
    }
}
