//
//  System.swift
//  Life
//
//  Created by Shyngys Kassymov on 03.03.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation

struct System: Codable {
    struct IconSize: Codable {
        var width: Int
        var height: Int
    }

    var name: String
    var href: String
    var type: String
    var iconStreamId: String
    var iconSize: IconSize
}
