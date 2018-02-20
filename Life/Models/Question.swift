//
//  Question.swift
//  Life
//
//  Created by Shyngys Kassymov on 19.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation

struct Question: Codable {
    var id: String
    var questionText: String
    var isAnonymous: Bool
    var tags: [String]
    var nsiTagIds: [String]
    var newTagNames: [String]

    // MARK: - Decodable

    enum CodingKeys: String, CodingKey {
        case id
        case questionText
        case isAnonymous
        case tags
        case nsiTagIds
        case newTagNames
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decodeWrapper(key: .id, defaultValue: UUID().uuidString)
        self.questionText = try container.decodeWrapper(key: .questionText, defaultValue: "")
        self.isAnonymous = try container.decodeWrapper(key: .isAnonymous, defaultValue: false)
        self.tags = try container.decodeWrapper(key: .tags, defaultValue: [])
        self.nsiTagIds = try container.decodeWrapper(key: .nsiTagIds, defaultValue: [])
        self.newTagNames = try container.decodeWrapper(key: .newTagNames, defaultValue: [])
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(questionText, forKey: "questionText")
        aCoder.encode(isAnonymous, forKey: "isAnonymous")
        aCoder.encode(tags, forKey: "tags")
        aCoder.encode(nsiTagIds, forKey: "nsiTagIds")
        aCoder.encode(newTagNames, forKey: "newTagNames")
    }
}
