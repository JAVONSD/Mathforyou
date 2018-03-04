//
//  Lenta.swift
//  Life
//
//  Created by Shyngys Kassymov on 17.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation

struct ImageSize: Codable {
    var width: Int
    var height: Int
}

struct LentaType: Codable {
    var name: String
    var code: EntityType
}

enum EntityType: Int, Codable {
    case news = 10, suggestion = 20, questionnaire = 30
}

struct Lenta: Decodable {
    var id: String
    var authorCode: String
    var authorName: String
    var createDate: String
    var title: String
    var description: String
    var image: String
    var imageStreamId: String?
    var imageSize: ImageSize
    var questionsQuantity: Int
    var commentsQuantity: Int
    var likesQuantity: Int
    var dislikesQuantity: Int
    var userVote: Int
    var isLikedByMe: Bool
    var viewsQuantity: Int
    var isFromSharepoint: Bool
    var entityType: LentaType

    init(news: News, authorIsCurrent: Bool = true) {
        self.id = news.id
        self.authorCode = authorIsCurrent ? User.current.employeeCode : news.authorCode
        self.authorName = authorIsCurrent
            ? (User.current.profile?.fullname ?? news.authorName)
            : news.authorName
        self.createDate = news.createDate
        self.title = news.title
        self.description = ""
        self.image = news.imageUrl
        self.imageStreamId = news.imageStreamId
        self.imageSize = .init(width: 200, height: 200)
        self.questionsQuantity = 0
        self.commentsQuantity = 0
        self.likesQuantity = 0
        self.dislikesQuantity = 0
        self.userVote = 0
        self.isLikedByMe = false
        self.viewsQuantity = 0
        self.isFromSharepoint = false
        self.entityType = .init(name: "News", code: .news)
    }

    init(suggestion: Suggestion, authorIsCurrent: Bool = true) {
        self.id = suggestion.id
        self.authorCode = authorIsCurrent ? User.current.employeeCode : suggestion.authorCode
        self.authorName = authorIsCurrent
            ? (User.current.profile?.fullname ?? suggestion.authorName)
            : suggestion.authorName
        self.createDate = suggestion.createDate
        self.title = suggestion.title
        self.description = ""
        self.image = suggestion.imageStreamId ?? ""
        self.imageStreamId = suggestion.imageStreamId
        self.imageSize = .init(width: 200, height: 200)
        self.questionsQuantity = 0
        self.commentsQuantity = 0
        self.likesQuantity = 0
        self.dislikesQuantity = 0
        self.userVote = 0
        self.isLikedByMe = false
        self.viewsQuantity = 0
        self.isFromSharepoint = false
        self.entityType = .init(name: "Suggestion", code: .suggestion)
    }

    // MARK: - Decodable

    enum CodingKeys: String, CodingKey {
        case id
        case authorCode
        case authorName
        case createDate
        case title
        case description
        case image = "imageUrl"
        case imageStreamId
        case imageSize
        case questionsQuantity
        case commentsQuantity
        case likesQuantity
        case dislikesQuantity
        case userVote
        case isLikedByMe
        case viewsQuantity
        case isFromSharepoint
        case entityType
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decodeWrapper(key: .id, defaultValue: UUID().uuidString)
        self.authorCode = try container.decodeWrapper(key: .authorCode, defaultValue: "")
        self.authorName = try container.decodeWrapper(key: .authorName, defaultValue: "")
        self.createDate = try container.decodeWrapper(key: .createDate, defaultValue: "")
        self.title = try container.decodeWrapper(key: .title, defaultValue: "")
        self.description = try container.decodeWrapper(key: .description, defaultValue: "")
        self.image = try container.decodeWrapper(key: .image, defaultValue: "")
        self.imageStreamId = try container.decodeWrapper(key: .imageStreamId, defaultValue: "")
        self.imageSize = try container.decodeWrapper(
            key: .imageSize,
            defaultValue: ImageSize(width: 0, height: 0)
        )
        self.questionsQuantity = try container.decodeWrapper(key: .questionsQuantity, defaultValue: 0)
        self.commentsQuantity = try container.decodeWrapper(key: .commentsQuantity, defaultValue: 0)
        self.likesQuantity = try container.decodeWrapper(key: .likesQuantity, defaultValue: 0)
        self.dislikesQuantity = try container.decodeWrapper(key: .dislikesQuantity, defaultValue: 0)
        self.userVote = try container.decodeWrapper(key: .userVote, defaultValue: 0)
        self.isLikedByMe = try container.decodeWrapper(key: .isLikedByMe, defaultValue: false)
        self.viewsQuantity = try container.decodeWrapper(key: .viewsQuantity, defaultValue: 0)
        self.isFromSharepoint = try container.decodeWrapper(key: .isFromSharepoint, defaultValue: false)
        self.entityType = try container.decodeWrapper(
            key: .entityType,
            defaultValue: LentaType(name: "News", code: .news)
        )
    }
}

extension KeyedDecodingContainer {
    func decodeWrapper<T>(key: K, defaultValue: T) throws -> T
        where T : Decodable {
            return try decodeIfPresent(T.self, forKey: key) ?? defaultValue
    }
}
