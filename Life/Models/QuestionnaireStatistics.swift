//
//  QuestionnaireStatistics.swift
//  Life
//
//  Created by Shyngys Kassymov on 28.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation

struct QuestionnaireStatistics: Codable {

    var id: String
    var createDate: String
    var authorCode: String
    var authorName: String
    var questions: [QuestionnaireQuestionStatistics]

    // MARK: - Decodable

    enum CodingKeys: String, CodingKey {
        case id
        case createDate
        case authorCode
        case authorName
        case questions
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decodeWrapper(key: .id, defaultValue: UUID().uuidString)
        self.createDate = try container.decodeWrapper(key: .createDate, defaultValue: "")
        self.authorCode = try container.decodeWrapper(key: .authorCode, defaultValue: "")
        self.authorName = try container.decodeWrapper(key: .authorName, defaultValue: "")
        self.questions = try container.decodeWrapper(key: .questions, defaultValue: [])
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(createDate, forKey: "createDate")
        aCoder.encode(authorCode, forKey: "authorCode")
        aCoder.encode(authorName, forKey: "authorName")
        aCoder.encode(questions, forKey: "questions")
    }

}

struct QuestionnaireQuestionStatistics: Codable {

    var questionText: String
    var variants: [QuestionnaireVariantStatistics]
    var commentVariant: QuestionnaireVariantStatistics?
    var totalVotes: Int

    // MARK: - Decodable

    enum CodingKeys: String, CodingKey {
        case questionText
        case variants
        case commentVariant
        case totalVotes
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.questionText = try container.decodeWrapper(key: .questionText, defaultValue: "")
        self.variants = try container.decodeWrapper(key: .variants, defaultValue: [])
        self.commentVariant = try container.decodeWrapper(key: .commentVariant, defaultValue: nil)
        self.totalVotes = try container.decodeWrapper(key: .totalVotes, defaultValue: 0)
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(questionText, forKey: "questionText")
        aCoder.encode(variants, forKey: "variants")
        aCoder.encode(commentVariant, forKey: "commentVariant")
        aCoder.encode(totalVotes, forKey: "totalVotes")
    }

}

struct QuestionnaireVariantStatistics: Codable {

    var variantText: String
    var percentage: Int

}
