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
    var createDate: String
    var imageStreamId: String
    var authorCode: String
    var authorName: String
    var secondaryImages: [Image]
    var questions: [Question]

    // MARK: - Decodable

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case createDate
        case imageStreamId
        case authorCode
        case authorName
        case secondaryImages
        case questions
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decodeWrapper(key: .id, defaultValue: UUID().uuidString)
        self.title = try container.decodeWrapper(key: .title, defaultValue: "")
        self.createDate = try container.decodeWrapper(key: .createDate, defaultValue: "")
        self.imageStreamId = try container.decodeWrapper(key: .imageStreamId, defaultValue: "")
        self.authorCode = try container.decodeWrapper(key: .authorCode, defaultValue: "")
        self.authorName = try container.decodeWrapper(key: .authorName, defaultValue: "")
        self.secondaryImages = try container.decodeWrapper(key: .secondaryImages, defaultValue: [])
        self.questions = try container.decodeWrapper(key: .questions, defaultValue: [])
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(createDate, forKey: "createDate")
        aCoder.encode(imageStreamId, forKey: "imageStreamId")
        aCoder.encode(authorCode, forKey: "authorCode")
        aCoder.encode(authorName, forKey: "authorName")
        aCoder.encode(secondaryImages, forKey: "secondaryImages")
        aCoder.encode(questions, forKey: "questions")
    }

}
