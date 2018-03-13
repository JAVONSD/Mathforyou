//
//  String+Extensions.swift
//  Life
//
//  Created by Shyngys Kassymov on 14.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import DateToolsSwift
import Moya

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

    public func multipartFormData(_ name: String) -> MultipartFormData {
        let data = MultipartFormData(
            provider: .data(self.utf8Encoded),
            name: name
        )
        return data
    }

    public func prettyDateString(format: String = "dd.MM.yyyy HH:mm") -> String {
        let date = self.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }

    public func prettyDateOrTimeAgoString(
        format: String = "dd.MM.yyyy HH:mm") -> String {
        let date = self.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let result = dateFormatter.string(from: date)

        if date.daysAgo > 0 {
            return result
        }
        return date.timeAgoSinceNow
    }

    public func html() -> String {
        return String(format:
            """
            <html>
            <head>
                <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
                <link rel="stylesheet" type="text/css" href="news.css">
            </head>
            <body>
                %@
            </body>
            </html>
            """, self)

    }

    public func onEmpty(_ defaultValue: String) -> String {
        return isEmpty ? defaultValue : self
    }

}
