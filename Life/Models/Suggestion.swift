//
//  Suggestion.swift
//  Life
//
//  Created by Shyngys Kassymov on 19.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation

struct Suggestion: Codable {

    var id: String
    var title: String
    var createDate: String
    var imageStreamId: String?
    var authorCode: String
    var authorName: String
    var canEdit: Bool
    var commentsQuantity: Int
    var likesQuantity: Int
    var dislikesQuantity: Int
    var userVote: Int
    var viewsQuantity: Int
    var comments: [Comment]
    var secondaryImages: [String]
    var tags: [Tag]

    // MARK: - Decodable

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case createDate
        case imageStreamId
        case authorCode
        case authorName
        case canEdit
        case commentsQuantity
        case likesQuantity
        case dislikesQuantity
        case userVote
        case viewsQuantity
        case comments
        case secondaryImages
        case tags
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decodeWrapper(key: .id, defaultValue: UUID().uuidString)
        self.title = try container.decodeWrapper(key: .title, defaultValue: "")
        self.createDate = try container.decodeWrapper(key: .createDate, defaultValue: "")
        self.imageStreamId = try container.decodeWrapper(key: .imageStreamId, defaultValue: "")
        self.authorCode = try container.decodeWrapper(key: .authorCode, defaultValue: "")
        self.authorName = try container.decodeWrapper(key: .authorName, defaultValue: "")
        self.canEdit = try container.decodeWrapper(key: .canEdit, defaultValue: false)
        self.commentsQuantity = try container.decodeWrapper(key: .commentsQuantity, defaultValue: 0)
        self.likesQuantity = try container.decodeWrapper(key: .likesQuantity, defaultValue: 0)
        self.dislikesQuantity = try container.decodeWrapper(key: .dislikesQuantity, defaultValue: 0)
        self.userVote = try container.decodeWrapper(key: .userVote, defaultValue: 0)
        self.viewsQuantity = try container.decodeWrapper(key: .viewsQuantity, defaultValue: 0)
        self.comments = try container.decodeWrapper(key: .comments, defaultValue: [])
        self.secondaryImages = try container.decodeWrapper(key: .secondaryImages, defaultValue: [])
        self.tags = try container.decodeWrapper(key: .tags, defaultValue: [])
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(createDate, forKey: "createDate")
        aCoder.encode(imageStreamId, forKey: "imageStreamId")
        aCoder.encode(authorCode, forKey: "authorCode")
        aCoder.encode(authorName, forKey: "authorName")
        aCoder.encode(canEdit, forKey: "canEdit")
        aCoder.encode(commentsQuantity, forKey: "commentsQuantity")
        aCoder.encode(likesQuantity, forKey: "likesQuantity")
        aCoder.encode(dislikesQuantity, forKey: "dislikesQuantity")
        aCoder.encode(userVote, forKey: "userVote")
        aCoder.encode(viewsQuantity, forKey: "viewsQuantity")
        aCoder.encode(comments, forKey: "comments")
        aCoder.encode(secondaryImages, forKey: "secondaryImages")
        aCoder.encode(tags, forKey: "tags")
    }

}
