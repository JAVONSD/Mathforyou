//
//  Tag.swift
//  Life
//
//  Created by Shyngys Kassymov on 19.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation

struct Tag: Codable, Hashable {

    var id: String
    var nsiTagId: String
    var name: String

    func getId() -> String {
        if nsiTagId.isEmpty {
            return id
        }
        return nsiTagId
    }

    // MARK: - Decodable

    enum CodingKeys: String, CodingKey {
        case id
        case nsiTagId
        case name
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decodeWrapper(key: .id, defaultValue: "")
        self.nsiTagId = try container.decodeWrapper(key: .nsiTagId, defaultValue: "")
        self.name = try container.decodeWrapper(key: .name, defaultValue: "")
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(nsiTagId, forKey: "nsiTagId")
        aCoder.encode(name, forKey: "name")

    }

    // MARK: - Hashable

    var hashValue: Int { return nsiTagId.hashValue }

    static func == (lhs: Tag, rhs: Tag) -> Bool {
        return lhs.nsiTagId == rhs.nsiTagId
    }

}
