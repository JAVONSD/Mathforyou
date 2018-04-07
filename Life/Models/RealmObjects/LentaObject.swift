//
//  LentaObject.swift
//  Life
//
//  Created by Shyngys Kassymov on 10.03.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import RealmSwift

class LentaObject: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var authorCode: String = ""
    @objc dynamic var authorName: String = ""
    @objc dynamic var createDate: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var descriptionText: String = ""
    @objc dynamic var image: String = ""
    @objc dynamic var imageStreamId: String?
    @objc dynamic var imageSize: ImageSizeObject?
    @objc dynamic var questionsQuantity: Int = 0
    @objc dynamic var commentsQuantity: Int = 0
    @objc dynamic var likesQuantity: Int = 0
    @objc dynamic var dislikesQuantity: Int = 0
    @objc dynamic var userVote: Int = 0
    @objc dynamic var isLikedByMe: Bool = false
    @objc dynamic var viewsQuantity: Int = 0
    @objc dynamic var isFromSharepoint: Bool = false
    @objc dynamic var isPublishedAsGroup: Bool = false
    @objc dynamic var entityType: LentaTypeObject?

    override static func primaryKey() -> String? {
        return "id"
    }
}

class ImageSizeObject: Object {
    @objc dynamic var width: Int = 0
    @objc dynamic var height: Int = 0
}

class LentaTypeObject: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var code: Int = EntityType.news.rawValue
}
