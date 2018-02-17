//
//  String+Extensions.swift
//  Life
//
//  Created by Shyngys Kassymov on 14.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation

public extension String {

    public var urlEscaped: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }

    public var utf8Encoded: Data {
        return data(using: .utf8)!
    }

    public var date: Date {
        let dateFormatter = DateFormatter()
        let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
        dateFormatter.locale = enUSPosixLocale
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"

        var date = dateFormatter.date(from: self)
        if date == nil {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            date = dateFormatter.date(from: self)
        }

        return date ?? Date()
    }

    public func prettyDateString(format: String) -> String {
        let date = self.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }

}
