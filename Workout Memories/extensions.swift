//
//  extensions.swift
//  extensions
//
//  Created by Lonnie Gerol on 8/16/21.
//

import HealthKit

class Style {

    // This method will determine unit based on a user preference
    static func distanceString(value: Double) -> String {
        return "\(value.formatted(.number.precision(.significantDigits(2)))) mi"
    }

    static func timeDurationString(_ dateRange: Range<Date>) -> String {
        return dateRange.formatted(.components(style: .abbreviated, fields: [.hour,.minute]))
    }

    static func timeDurationString(_ timeInterval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .short
        formatter.allowedUnits = [.hour, .minute]
        return  formatter.string(from: timeInterval) ?? ""
    }

}
