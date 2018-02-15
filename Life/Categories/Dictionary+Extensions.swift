//
//  Dictionary+Extensions.swift
//  Life
//
//  Created by Shyngys Kassymov on 14.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation

extension Dictionary {

    public func toJSON() -> String {
        let jsonData = try? JSONSerialization.data(
            withJSONObject: self,
            options: .prettyPrinted
        )
        guard let theJSONData = jsonData, let theJSONText = String(
            data: theJSONData,
            encoding: String.Encoding.utf8
            ) else {
                return "{}"
        }
        return theJSONText
    }

    public func toJSONData() -> Data {
        let jsonData = try? JSONSerialization.data(
            withJSONObject: self,
            options: .prettyPrinted
        )
        return jsonData ?? "{}".utf8Encoded
    }

}
