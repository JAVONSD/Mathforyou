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

// MARK: - Persistable

extension QuestionnaireStatistics: Persistable {
    init(managedObject: QuestionnaireStatisticsObject) {
        id = managedObject.id
        createDate = managedObject.createDate
        authorCode = managedObject.authorCode
        authorName = managedObject.authorName
        questions = managedObject.questions.map { QuestionnaireQuestionStatistics(managedObject: $0) }
    }

    func managedObject() -> QuestionnaireStatisticsObject {
        let object = QuestionnaireStatisticsObject()
        object.id = id
        object.createDate = createDate
        object.authorCode = authorCode
        object.authorName = authorName
        object.questions.append(objectsIn: questions.map { $0.managedObject() })
        return object
    }
}

extension QuestionnaireQuestionStatistics: Persistable {
    init(managedObject: QuestionnaireQuestionStatisticsObject) {
        questionText = managedObject.questionText
        variants = managedObject.variants.map { QuestionnaireVariantStatistics(managedObject: $0) }

        if let commentVariant = managedObject.commentVariant {
            self.commentVariant = QuestionnaireVariantStatistics(managedObject: commentVariant)
        } else {
            self.commentVariant = nil
        }

        totalVotes = managedObject.totalVotes
    }

    func managedObject() -> QuestionnaireQuestionStatisticsObject {
        let object = QuestionnaireQuestionStatisticsObject()
        object.questionText = questionText
        object.variants.append(objectsIn: variants.map { $0.managedObject() })
        object.commentVariant = commentVariant?.managedObject()
        object.totalVotes = totalVotes
        return object
    }
}

extension QuestionnaireVariantStatistics: Persistable {
    init(managedObject: QuestionnaireVariantStatisticsObject) {
        variantText = managedObject.variantText
        percentage = managedObject.percentage
    }

    func managedObject() -> QuestionnaireVariantStatisticsObject {
        let object = QuestionnaireVariantStatisticsObject()
        object.variantText = variantText
        object.percentage = percentage
        return object
    }
}
