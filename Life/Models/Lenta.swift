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

enum EntityType: Int, Codable {
    case news = 10, questionnaire = 20, suggestion = 30
}

struct Lenta: Decodable {
    var id: String
    var authorCode: String
    var authorAvatar: String
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
    var entityType: EntityType

    // MARK: - Decodable

    enum CodingKeys: String, CodingKey {
        case id
        case authorCode
        case authorAvatar
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
        case entityType = "entityType.code"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decodeWrapper(key: .id, defaultValue: UUID().uuidString)
        self.authorCode = try container.decodeWrapper(key: .authorCode, defaultValue: "")
        self.authorAvatar = try container.decodeWrapper(key: .authorAvatar, defaultValue: "")
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
        self.entityType = try container.decodeWrapper(key: .entityType, defaultValue: .news)
    }
}

extension KeyedDecodingContainer {
    func decodeWrapper<T>(key: K, defaultValue: T) throws -> T
        where T : Decodable {
            return try decodeIfPresent(T.self, forKey: key) ?? defaultValue
    }
}
