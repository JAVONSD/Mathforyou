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

enum ResultsType: Int {
    case all, top3, popular
}

struct Lenta: Decodable, Hashable {
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
        self.commentsQuantity = news.commentsQuantity
        self.likesQuantity = news.likesQuantity
        self.dislikesQuantity = 0
        self.userVote = 0
        self.isLikedByMe = news.isLikedByMe
        self.viewsQuantity = news.viewsQuantity
        self.isFromSharepoint = news.isFromSharepoint
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
        self.commentsQuantity = suggestion.commentsQuantity
        self.likesQuantity = suggestion.likesQuantity
        self.dislikesQuantity = suggestion.dislikesQuantity
        self.userVote = suggestion.userVote.rawValue
        self.isLikedByMe = suggestion.userVote == .liked
        self.viewsQuantity = suggestion.viewsQuantity
        self.isFromSharepoint = false
        self.entityType = .init(name: "Suggestion", code: .suggestion)
    }

    init(questionnaire: Questionnaire, authorIsCurrent: Bool = true) {
        self.id = questionnaire.id
        self.authorCode = authorIsCurrent ? User.current.employeeCode : questionnaire.authorCode
        self.authorName = authorIsCurrent
            ? (User.current.profile?.fullname ?? questionnaire.authorName)
            : questionnaire.authorName
        self.createDate = questionnaire.createDate
        self.title = questionnaire.title
        self.description = ""
        self.image = questionnaire.imageStreamId
        self.imageStreamId = questionnaire.imageStreamId
        self.imageSize = .init(width: 200, height: 200)
        self.questionsQuantity = 0
        self.commentsQuantity = 0
        self.likesQuantity = 0
        self.dislikesQuantity = 0
        self.userVote = 0
        self.isLikedByMe = false
        self.viewsQuantity = 0
        self.isFromSharepoint = false
        self.entityType = .init(name: "Questionnaire", code: .questionnaire)
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

    // MARK: - Hashable

    var hashValue: Int {
        return id.hashValue
    }

    static func == (lhs: Lenta, rhs: Lenta) -> Bool {
        return rhs.id == lhs.id
    }
}

// MARK: - Persistable

extension Lenta: Persistable {
    init(managedObject: LentaObject) {
        id = managedObject.id
        authorCode = managedObject.authorCode
        authorName = managedObject.authorName
        createDate = managedObject.createDate
        title = managedObject.title
        description = managedObject.descriptionText
        image = managedObject.image
        imageStreamId = managedObject.imageStreamId

        let imageSize = managedObject.imageSize ?? ImageSizeObject()
        self.imageSize = ImageSize(managedObject: imageSize)

        questionsQuantity = managedObject.questionsQuantity
        commentsQuantity = managedObject.commentsQuantity
        likesQuantity = managedObject.likesQuantity
        dislikesQuantity = managedObject.dislikesQuantity
        userVote = managedObject.userVote
        isLikedByMe = managedObject.isLikedByMe
        viewsQuantity = managedObject.viewsQuantity
        isFromSharepoint = managedObject.isFromSharepoint

        let entityType = managedObject.entityType ?? LentaTypeObject()
        self.entityType = LentaType(managedObject: entityType)
    }

    func managedObject() -> LentaObject {
        let object = LentaObject()
        object.id = id
        object.authorCode = authorCode
        object.authorName = authorName
        object.createDate = createDate
        object.title = title
        object.descriptionText = description
        object.image = image
        object.imageStreamId = imageStreamId
        object.imageSize = imageSize.managedObject()
        object.questionsQuantity = questionsQuantity
        object.commentsQuantity = commentsQuantity
        object.likesQuantity = likesQuantity
        object.dislikesQuantity = dislikesQuantity
        object.userVote = userVote
        object.isLikedByMe = isLikedByMe
        object.viewsQuantity = viewsQuantity
        object.isFromSharepoint = isFromSharepoint
        object.entityType = entityType.managedObject()
        return object
    }
}

extension ImageSize: Persistable {
    init(managedObject: ImageSizeObject) {
        width = managedObject.width
        height = managedObject.height
    }

    func managedObject() -> ImageSizeObject {
        let object = ImageSizeObject()
        object.width = width
        object.height = height
        return object
    }
}

extension LentaType: Persistable {
    init(managedObject: LentaTypeObject) {
        name = managedObject.name
        code = EntityType(rawValue: managedObject.code) ?? .news
    }

    func managedObject() -> LentaTypeObject {
        let object = LentaTypeObject()
        object.name = name
        object.code = code.rawValue
        return object
    }
}

// MARK: - KeyedDecodingContainer

extension KeyedDecodingContainer {
    func decodeWrapper<T>(key: K, defaultValue: T) throws -> T
        where T : Decodable {
            return try decodeIfPresent(T.self, forKey: key) ?? defaultValue
    }
}
