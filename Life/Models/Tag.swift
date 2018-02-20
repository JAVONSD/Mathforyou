//
//  Tag.swift
//  Life
//
//  Created by Shyngys Kassymov on 19.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation

struct Tag: Codable {

    var nsiTagId: String
    var name: String

    // MARK: - Decodable

    enum CodingKeys: String, CodingKey {
        case nsiTagId
        case name
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.nsiTagId = try container.decodeWrapper(key: .nsiTagId, defaultValue: UUID().uuidString)
        self.name = try container.decodeWrapper(key: .name, defaultValue: "")
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(nsiTagId, forKey: "nsiTagId")
        aCoder.encode(name, forKey: "name")

    }

}
