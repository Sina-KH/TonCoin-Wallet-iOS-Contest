//
//  DateUtils.swift
//  WalletContext
//
//  Created by Sina on 5/18/23.
//

import Foundation

extension Date {
    func isEqual(to date: Date, toGranularity component: Calendar.Component, in calendar: Calendar = .current) -> Bool {
        calendar.isDate(self, equalTo: date, toGranularity: component)
    }

    public func isInSameDay(as date: Date) -> Bool { Calendar.current.isDate(self, inSameDayAs: date) }

    public func isInSameYear(as date: Date) -> Bool { isEqual(to: date, toGranularity: .year) }
}
