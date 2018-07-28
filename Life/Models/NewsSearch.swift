//
//  NewsSearch.swift
//  Life
//
//  Created by 123 on 28.07.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation

struct NewsSearch: Codable, Hashable {
    
    var entityName: String
    var entityType: Int
    var id: String
    var title: String
    var body: String
    
    // MARK: - Decodable
    
    enum CodingKeys: String, CodingKey {
        case entityName
        case entityType
        case id
        case title
        case body
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.entityName = try container.decodeWrapper(key: .entityName, defaultValue: "News")
        self.entityType = try container.decodeWrapper(key: .entityType, defaultValue: 60)
        self.id = try container.decodeWrapper(key: .id, defaultValue: UUID().uuidString)
        self.title = try container.decodeWrapper(key: .title, defaultValue: "")
        self.body = try container.decodeWrapper(key: .body, defaultValue: "")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "entityName")
        aCoder.encode(id, forKey: "entityType")
        aCoder.encode(id, forKey: "id")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(body, forKey: "body")
    }
    
    // MARK: - Hashable
    
    var hashValue: Int {
        return id.hashValue
    }
    
    static func == (lhs: NewsSearch, rhs: NewsSearch) -> Bool {
        return rhs.id == lhs.id
    }
    
}

// MARK: - Persistable

//extension NewsSearch: Persistable {
//    init(managedObject: NewsObject) {
//        id = managedObject.id
//        title = managedObject.title
//        text = managedObject.text
//        createDate = managedObject.createDate
//        imageStreamId = managedObject.imageStreamId
//        
//        let imageSize = managedObject.imageSize ?? ImageSizeObject()
//        self.imageSize = ImageSize(managedObject: imageSize)
//        
//        imageUrl = managedObject.imageUrl
//        authorCode = managedObject.authorCode
//        authorName = managedObject.authorName
//        commentsQuantity = managedObject.commentsQuantity
//        likesQuantity = managedObject.likesQuantity
//        isLikedByMe = managedObject.isLikedByMe
//        viewsQuantity = managedObject.viewsQuantity
//        isHistoryEvent = managedObject.isHistoryEvent
//        isFromSharepoint = managedObject.isFromSharepoint
//        isPublishedAsGroup = managedObject.isPublishedAsGroup
//        comments = managedObject.comments.map { Comment(managedObject: $0) }
//        secondaryImages = managedObject.secondaryImages.map { Image(managedObject: $0) }
//        tags = managedObject.tags.map { Tag(managedObject: $0) }
//    }
//    
//    func managedObject() -> NewsObject {
//        let object = NewsObject()
//        object.id = id
//        object.title = title
//        object.text = text
//        object.createDate = createDate
//        object.imageStreamId = imageStreamId
//        object.imageSize = imageSize.managedObject()
//        object.imageUrl = imageUrl
//        object.authorCode = authorCode
//        object.authorName = authorName
//        object.commentsQuantity = commentsQuantity
//        object.likesQuantity = likesQuantity
//        object.isLikedByMe = isLikedByMe
//        object.viewsQuantity = viewsQuantity
//        object.isHistoryEvent = isHistoryEvent
//        object.isFromSharepoint = isFromSharepoint
//        object.isPublishedAsGroup = isPublishedAsGroup
//        object.comments.append(objectsIn: comments.map { $0.managedObject() })
//        object.secondaryImages.append(objectsIn: secondaryImages.map { $0.managedObject() })
//        object.tags.append(objectsIn: tags.map { $0.managedObject() })
//        return object
//    }
//}






