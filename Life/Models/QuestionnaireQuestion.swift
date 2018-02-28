//
//  QuestionnaireQuestion.swift
//  Life
//
//  Created by Shyngys Kassymov on 28.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation

struct QuestionnaireQuestion: Codable {

    var id: String
    var text: String
    var minAnswersQuantity: Int
    var maxAnswersQuantity: Int
    var variants: [QuestionnaireVariant]
    var userAnswer: [String]
    var userComment: String
    var canComment: Bool
    var totalAnswers: Int

    // MARK: - Decodable

    enum CodingKeys: String, CodingKey {
        case id
        case text
        case minAnswersQuantity
        case maxAnswersQuantity
        case variants
        case userAnswer
        case userComment
        case canComment
        case totalAnswers
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decodeWrapper(key: .id, defaultValue: UUID().uuidString)
        self.text = try container.decodeWrapper(key: .text, defaultValue: "")
        self.minAnswersQuantity = try container.decodeWrapper(key: .minAnswersQuantity, defaultValue: 0)
        self.maxAnswersQuantity = try container.decodeWrapper(key: .maxAnswersQuantity, defaultValue: 0)
        self.variants = try container.decodeWrapper(key: .variants, defaultValue: [])
        self.userAnswer = try container.decodeWrapper(key: .userAnswer, defaultValue: [])
        self.userComment = try container.decodeWrapper(key: .userComment, defaultValue: "")
        self.canComment = try container.decodeWrapper(key: .canComment, defaultValue: false)
        self.totalAnswers = try container.decodeWrapper(key: .totalAnswers, defaultValue: 0)
    }

}

struct QuestionnaireVariant: Codable {

    var id: String
    var text: String

}
