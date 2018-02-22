//
//  Answer.swift
//  Life
//
//  Created by Shyngys Kassymov on 19.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation

struct Answer: Codable {

    var id: String
    var questionText: String
    var createDate: String
    var text: String
    var authorCode: String
    var authorName: String
    var jobPosition: String
    var videoStreamId: String
    var likesQuantity: Int
    var viewsQuantity: Int
    var answersQuantity: Int
    var isLikedByMe: Bool

    // MARK: - Decodable

    enum CodingKeys: String, CodingKey {
        case id
        case questionText
        case createDate
        case text
        case authorCode
        case authorName
        case jobPosition
        case videoStreamId
        case likesQuantity
        case viewsQuantity
        case answersQuantity
        case isLikedByMe
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decodeWrapper(key: .id, defaultValue: UUID().uuidString)
        self.questionText = try container.decodeWrapper(key: .questionText, defaultValue: "")
        self.createDate = try container.decodeWrapper(key: .createDate, defaultValue: "")
        self.text = try container.decodeWrapper(key: .text, defaultValue: "")
        self.authorCode = try container.decodeWrapper(key: .authorCode, defaultValue: "")
        self.authorName = try container.decodeWrapper(key: .authorName, defaultValue: "")
        self.jobPosition = try container.decodeWrapper(key: .jobPosition, defaultValue: "")
        self.videoStreamId = try container.decodeWrapper(key: .videoStreamId, defaultValue: "")
        self.likesQuantity = try container.decodeWrapper(key: .likesQuantity, defaultValue: 0)
        self.viewsQuantity = try container.decodeWrapper(key: .viewsQuantity, defaultValue: 0)
        self.answersQuantity = try container.decodeWrapper(key: .answersQuantity, defaultValue: 0)
        self.isLikedByMe = try container.decodeWrapper(key: .isLikedByMe, defaultValue: false)
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(questionText, forKey: "questionText")
        aCoder.encode(createDate, forKey: "createDate")
        aCoder.encode(text, forKey: "text")
        aCoder.encode(authorCode, forKey: "authorCode")
        aCoder.encode(authorName, forKey: "authorName")
        aCoder.encode(jobPosition, forKey: "jobPosition")
        aCoder.encode(videoStreamId, forKey: "videoStreamId")
        aCoder.encode(likesQuantity, forKey: "likesQuantity")
        aCoder.encode(viewsQuantity, forKey: "viewsQuantity")
        aCoder.encode(answersQuantity, forKey: "answersQuantity")
        aCoder.encode(isLikedByMe, forKey: "isLikedByMe")
    }

}

struct AnswerAuthor: Codable {

    var code: String
    var name: String
    var jobPosition: String
    var likesQuantity: Int
    var answersQuantity: Int
    var viewsQuantity: Int
    var isLikedByMe: Bool

    // MARK: - Decodable

    enum CodingKeys: String, CodingKey {
        case code
        case name
        case jobPosition
        case likesQuantity
        case answersQuantity
        case viewsQuantity
        case isLikedByMe
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.code = try container.decodeWrapper(key: .code, defaultValue: UUID().uuidString)
        self.name = try container.decodeWrapper(key: .name, defaultValue: "")
        self.jobPosition = try container.decodeWrapper(key: .jobPosition, defaultValue: "")
        self.likesQuantity = try container.decodeWrapper(key: .likesQuantity, defaultValue: 0)
        self.answersQuantity = try container.decodeWrapper(key: .answersQuantity, defaultValue: 0)
        self.viewsQuantity = try container.decodeWrapper(key: .viewsQuantity, defaultValue: 0)
        self.isLikedByMe = try container.decodeWrapper(key: .isLikedByMe, defaultValue: false)
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(code, forKey: "code")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(jobPosition, forKey: "jobPosition")
        aCoder.encode(likesQuantity, forKey: "likesQuantity")
        aCoder.encode(answersQuantity, forKey: "answersQuantity")
        aCoder.encode(viewsQuantity, forKey: "viewsQuantity")
        aCoder.encode(isLikedByMe, forKey: "isLikedByMe")
    }

}
