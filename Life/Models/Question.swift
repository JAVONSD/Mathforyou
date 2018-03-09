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
    var text: String
    var createDate: String
    var authorCode: String
    var authorName: String
    var canAnswer: Bool
    var answers: [Answer]
    var tags: [Tag]
    var likesQuantity: Int
    var viewsQuantity: Int
    var isLikedByMe: Bool

    // MARK: - Decodable

    enum CodingKeys: String, CodingKey {
        case id
        case text
        case createDate
        case authorCode
        case authorName
        case canAnswer
        case answers
        case tags
        case likesQuantity
        case viewsQuantity
        case isLikedByMe
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decodeWrapper(key: .id, defaultValue: UUID().uuidString)
        self.text = try container.decodeWrapper(key: .text, defaultValue: "")
        self.createDate = try container.decodeWrapper(key: .createDate, defaultValue: "")
        self.authorCode = try container.decodeWrapper(key: .authorCode, defaultValue: "")
        self.authorName = try container.decodeWrapper(key: .authorName, defaultValue: "")
        self.canAnswer = try container.decodeWrapper(key: .canAnswer, defaultValue: false)
        self.answers = try container.decodeWrapper(key: .answers, defaultValue: [])
        self.tags = try container.decodeWrapper(key: .tags, defaultValue: [])
        self.likesQuantity = try container.decodeWrapper(key: .likesQuantity, defaultValue: 0)
        self.viewsQuantity = try container.decodeWrapper(key: .viewsQuantity, defaultValue: 0)
        self.isLikedByMe = try container.decodeWrapper(key: .isLikedByMe, defaultValue: false)
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(text, forKey: "text")
        aCoder.encode(createDate, forKey: "createDate")
        aCoder.encode(authorCode, forKey: "authorCode")
        aCoder.encode(authorName, forKey: "authorName")
        aCoder.encode(canAnswer, forKey: "canAnswer")
        aCoder.encode(answers, forKey: "answers")
        aCoder.encode(tags, forKey: "tags")
        aCoder.encode(likesQuantity, forKey: "likesQuantity")
        aCoder.encode(viewsQuantity, forKey: "viewsQuantity")
        aCoder.encode(isLikedByMe, forKey: "isLikedByMe")
    }
}

extension Question: Hashable {
    var hashValue: Int {
        return id.hashValue
    }

    static func ==(lhs: Question, rhs: Question) -> Bool {
        return lhs.id == rhs.id
    }
}
