//
//  News.swift
//  Life
//
//  Created by Shyngys Kassymov on 19.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation

struct News: Codable, Hashable {

    var id: String
    var title: String
    var text: String
    var createDate: String
    var imageStreamId: String?
    var imageSize: ImageSize
    var imageUrl: String
    var authorCode: String
    var authorName: String
    var commentsQuantity: Int
    var likesQuantity: Int
    var isLikedByMe: Bool
    var viewsQuantity: Int
    var isHistoryEvent: Bool
    var isFromSharepoint: Bool
    var isPublishedAsGroup: Bool
    var comments: [Comment]
    var secondaryImages: [Image]
    var tags: [Tag]

    // MARK: - Decodable

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case text
        case createDate
        case imageStreamId
        case imageSize
        case imageUrl
        case authorCode
        case authorName
        case commentsQuantity
        case likesQuantity
        case isLikedByMe
        case viewsQuantity
        case isHistoryEvent
        case isFromSharepoint
        case isPublishedAsGroup
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
        self.imageSize = try container.decodeWrapper(
            key: .imageSize,
            defaultValue: ImageSize(width: 200, height: 200)
        )
        self.imageUrl = try container.decodeWrapper(key: .imageUrl, defaultValue: "")
        self.authorCode = try container.decodeWrapper(key: .authorCode, defaultValue: "")
        self.authorName = try container.decodeWrapper(key: .authorName, defaultValue: "")
        self.commentsQuantity = try container.decodeWrapper(key: .commentsQuantity, defaultValue: 0)
        self.likesQuantity = try container.decodeWrapper(key: .likesQuantity, defaultValue: 0)
        self.isLikedByMe = try container.decodeWrapper(key: .isLikedByMe, defaultValue: false)
        self.viewsQuantity = try container.decodeWrapper(key: .viewsQuantity, defaultValue: 0)
        self.isHistoryEvent = try container.decodeWrapper(key: .isHistoryEvent, defaultValue: false)
        self.isFromSharepoint = try container.decodeWrapper(key: .isFromSharepoint, defaultValue: false)
        self.isPublishedAsGroup = try container.decodeWrapper(key: .isPublishedAsGroup, defaultValue: false)
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
        aCoder.encode(imageSize, forKey: "imageSize")
        aCoder.encode(imageUrl, forKey: "imageUrl")
        aCoder.encode(authorCode, forKey: "authorCode")
        aCoder.encode(authorName, forKey: "authorName")
        aCoder.encode(commentsQuantity, forKey: "commentsQuantity")
        aCoder.encode(likesQuantity, forKey: "likesQuantity")
        aCoder.encode(isLikedByMe, forKey: "isLikedByMe")
        aCoder.encode(viewsQuantity, forKey: "viewsQuantity")
        aCoder.encode(isHistoryEvent, forKey: "isHistoryEvent")
        aCoder.encode(isFromSharepoint, forKey: "isFromSharepoint")
        aCoder.encode(isPublishedAsGroup, forKey: "isPublishedAsGroup")
        aCoder.encode(comments, forKey: "comments")
        aCoder.encode(secondaryImages, forKey: "secondaryImages")
        aCoder.encode(tags, forKey: "tags")
    }

    // MARK: - Hashable

    var hashValue: Int {
        return id.hashValue
    }

    static func == (lhs: News, rhs: News) -> Bool {
        return rhs.id == lhs.id
    }

}

// MARK: - Persistable

extension News: Persistable {
    init(managedObject: NewsObject) {
        id = managedObject.id
        title = managedObject.title
        text = managedObject.text
        createDate = managedObject.createDate
        imageStreamId = managedObject.imageStreamId

        let imageSize = managedObject.imageSize ?? ImageSizeObject()
        self.imageSize = ImageSize(managedObject: imageSize)

        imageUrl = managedObject.imageUrl
        authorCode = managedObject.authorCode
        authorName = managedObject.authorName
        commentsQuantity = managedObject.commentsQuantity
        likesQuantity = managedObject.likesQuantity
        isLikedByMe = managedObject.isLikedByMe
        viewsQuantity = managedObject.viewsQuantity
        isHistoryEvent = managedObject.isHistoryEvent
        isFromSharepoint = managedObject.isFromSharepoint
        isPublishedAsGroup = managedObject.isPublishedAsGroup
        comments = managedObject.comments.map { Comment(managedObject: $0) }
        secondaryImages = managedObject.secondaryImages.map { Image(managedObject: $0) }
        tags = managedObject.tags.map { Tag(managedObject: $0) }
    }

    func managedObject() -> NewsObject {
        let object = NewsObject()
        object.id = id
        object.title = title
        object.text = text
        object.createDate = createDate
        object.imageStreamId = imageStreamId
        object.imageSize = imageSize.managedObject()
        object.imageUrl = imageUrl
        object.authorCode = authorCode
        object.authorName = authorName
        object.commentsQuantity = commentsQuantity
        object.likesQuantity = likesQuantity
        object.isLikedByMe = isLikedByMe
        object.viewsQuantity = viewsQuantity
        object.isHistoryEvent = isHistoryEvent
        object.isFromSharepoint = isFromSharepoint
        object.isPublishedAsGroup = isPublishedAsGroup
        object.comments.append(objectsIn: comments.map { $0.managedObject() })
        object.secondaryImages.append(objectsIn: secondaryImages.map { $0.managedObject() })
        object.tags.append(objectsIn: tags.map { $0.managedObject() })
        return object
    }
}
