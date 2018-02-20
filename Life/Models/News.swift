//
//  News.swift
//  Life
//
//  Created by Shyngys Kassymov on 19.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation

struct News: Codable {

    var id: String
    var title: String
    var text: String
    var createDate: String
    var imageStreamId: String?
    var imageUrl: String
    var authorCode: String
    var authorName: String
    var commentsQuantity: Int
    var likesQuantity: Int
    var isLikedByMe: Bool
    var viewsQuantity: Int
    var isHistoryEvent: Bool
    var isFromSharepoint: Bool
    var comments: [Comment]
    var secondaryImages: [String]
    var tags: [Tag]

    // MARK: - Decodable

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case text
        case createDate
        case imageStreamId
        case imageUrl
        case authorCode
        case authorName
        case commentsQuantity
        case likesQuantity
        case isLikedByMe
        case viewsQuantity
        case isHistoryEvent
        case isFromSharepoint
        case comments
        case secondaryImages
        case tags
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decodeWrapper(key: .id, defaultValue: UUID().uuidString)
        self.title = try container.decodeWrapper(key: .title, defaultValue: "")
        self.text = try container.decodeWrapper(key: .text, defaultValue: "")
        self.createDate = try container.decodeWrapper(key: .createDate, defaultValue: "")
        self.imageStreamId = try container.decodeWrapper(key: .imageStreamId, defaultValue: "")
        self.imageUrl = try container.decodeWrapper(key: .imageUrl, defaultValue: "")
        self.authorCode = try container.decodeWrapper(key: .authorCode, defaultValue: "")
        self.authorName = try container.decodeWrapper(key: .authorName, defaultValue: "")
        self.commentsQuantity = try container.decodeWrapper(key: .commentsQuantity, defaultValue: 0)
        self.likesQuantity = try container.decodeWrapper(key: .likesQuantity, defaultValue: 0)
        self.isLikedByMe = try container.decodeWrapper(key: .isLikedByMe, defaultValue: false)
        self.viewsQuantity = try container.decodeWrapper(key: .viewsQuantity, defaultValue: 0)
        self.isHistoryEvent = try container.decodeWrapper(key: .isHistoryEvent, defaultValue: false)
        self.isFromSharepoint = try container.decodeWrapper(key: .isFromSharepoint, defaultValue: false)
        self.comments = try container.decodeWrapper(key: .comments, defaultValue: [])
        self.secondaryImages = try container.decodeWrapper(key: .secondaryImages, defaultValue: [])
        self.tags = try container.decodeWrapper(key: .tags, defaultValue: [])
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(text, forKey: "text")
        aCoder.encode(createDate, forKey: "createDate")
        aCoder.encode(imageStreamId, forKey: "imageStreamId")
        aCoder.encode(imageUrl, forKey: "imageUrl")
        aCoder.encode(authorCode, forKey: "authorCode")
        aCoder.encode(authorName, forKey: "authorName")
        aCoder.encode(commentsQuantity, forKey: "commentsQuantity")
        aCoder.encode(likesQuantity, forKey: "likesQuantity")
        aCoder.encode(isLikedByMe, forKey: "isLikedByMe")
        aCoder.encode(viewsQuantity, forKey: "viewsQuantity")
        aCoder.encode(isHistoryEvent, forKey: "isHistoryEvent")
        aCoder.encode(isFromSharepoint, forKey: "isFromSharepoint")
        aCoder.encode(comments, forKey: "comments")
        aCoder.encode(secondaryImages, forKey: "secondaryImages")
        aCoder.encode(tags, forKey: "tags")
    }

}
