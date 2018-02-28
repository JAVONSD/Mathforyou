//
//  Questionnaire.swift
//  Life
//
//  Created by Shyngys Kassymov on 19.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation

struct Questionnaire: Codable {

    var id: String
    var title: String
    var description: String
    var createDate: String
    var imageStreamId: String
    var authorCode: String
    var authorName: String
    var secondaryImages: [Image]
    var questions: [QuestionnaireQuestion]
    var questionsQuantity: Int
    var isAnonymous: Bool
    var answeredEmployeeQuantity: Int

    // MARK: - Decodable

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case createDate
        case imageStreamId
        case authorCode
        case authorName
        case secondaryImages
        case questions
        case questionsQuantity
        case isAnonymous
        case answeredEmployeeQuantity
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decodeWrapper(key: .id, defaultValue: UUID().uuidString)
        self.title = try container.decodeWrapper(key: .title, defaultValue: "")
        self.description = try container.decodeWrapper(key: .description, defaultValue: "")
        self.createDate = try container.decodeWrapper(key: .createDate, defaultValue: "")
        self.imageStreamId = try container.decodeWrapper(key: .imageStreamId, defaultValue: "")
        self.authorCode = try container.decodeWrapper(key: .authorCode, defaultValue: "")
        self.authorName = try container.decodeWrapper(key: .authorName, defaultValue: "")
        self.secondaryImages = try container.decodeWrapper(key: .secondaryImages, defaultValue: [])
        self.questions = try container.decodeWrapper(key: .questions, defaultValue: [])
        self.questionsQuantity = try container.decodeWrapper(key: .questionsQuantity, defaultValue: 0)
        self.isAnonymous = try container.decodeWrapper(key: .isAnonymous, defaultValue: false)
        self.answeredEmployeeQuantity = try container.decodeWrapper(
            key: .answeredEmployeeQuantity,
            defaultValue: 0
        )
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(description, forKey: "description")
        aCoder.encode(createDate, forKey: "createDate")
        aCoder.encode(imageStreamId, forKey: "imageStreamId")
        aCoder.encode(authorCode, forKey: "authorCode")
        aCoder.encode(authorName, forKey: "authorName")
        aCoder.encode(secondaryImages, forKey: "secondaryImages")
        aCoder.encode(questions, forKey: "questions")
        aCoder.encode(questionsQuantity, forKey: "questionsQuantity")
        aCoder.encode(isAnonymous, forKey: "isAnonymous")
        aCoder.encode(answeredEmployeeQuantity, forKey: "answeredEmployeeQuantity")
    }

}
