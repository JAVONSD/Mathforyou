//
//  NewsObject.swift
//  Life
//
//  Created by Shyngys Kassymov on 10.03.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import RealmSwift

class NewsObject: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var text: String = ""
    @objc dynamic var createDate: String = ""
    @objc dynamic var imageStreamId: String?
    @objc dynamic var imageSize: ImageSizeObject?
    @objc dynamic var imageUrl: String = ""
    @objc dynamic var authorCode: String = ""
    @objc dynamic var authorName: String = ""
    @objc dynamic var commentsQuantity: Int = 0
    @objc dynamic var likesQuantity: Int = 0
    @objc dynamic var isLikedByMe: Bool = false
    @objc dynamic var viewsQuantity: Int = 0
    @objc dynamic var isHistoryEvent: Bool = false
    @objc dynamic var isFromSharepoint: Bool = false
    @objc dynamic var isPublishedAsGroup: Bool = false
    let comments = List<CommentObject>()
    let secondaryImages = List<ImageObject>()
    let tags = List<TagObject>()

    override static func primaryKey() -> String? {
        return "id"
    }
}






