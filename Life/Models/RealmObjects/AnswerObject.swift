//
//  AnswerObject.swift
//  Life
//
//  Created by Shyngys Kassymov on 12.03.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import RealmSwift

class AnswerObject: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var questionText: String = ""
    @objc dynamic var createDate: String = ""
    @objc dynamic var text: String = ""
    @objc dynamic var authorCode: String = ""
    @objc dynamic var authorName: String = ""
    @objc dynamic var jobPosition: String = ""
    @objc dynamic var videoStreamId: String = ""
    @objc dynamic var likesQuantity: Int = 0
    @objc dynamic var viewsQuantity: Int = 0
    @objc dynamic var answersQuantity: Int = 0
    @objc dynamic var isLikedByMe: Bool = false

    override static func primaryKey() -> String? {
        return "id"
    }
}

class AnswerAuthorObject: Object {
    @objc dynamic var code: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var jobPosition: String = ""
    @objc dynamic var likesQuantity: Int = 0
    @objc dynamic var answersQuantity: Int = 0
    @objc dynamic var viewsQuantity: Int = 0
    @objc dynamic var isLikedByMe: Bool = false

    override static func primaryKey() -> String? {
        return "code"
    }
}
