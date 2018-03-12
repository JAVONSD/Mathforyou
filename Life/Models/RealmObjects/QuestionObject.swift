//
//  QuestionObject.swift
//  Life
//
//  Created by Shyngys Kassymov on 12.03.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import RealmSwift

class QuestionObject: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var text: String = ""
    @objc dynamic var createDate: String = ""
    @objc dynamic var authorCode: String = ""
    @objc dynamic var authorName: String = ""
    @objc dynamic var canAnswer: Bool = false
    let answers = List<AnswerObject>()
    let tags = List<TagObject>()
    @objc dynamic var likesQuantity: Int = 0
    @objc dynamic var viewsQuantity: Int = 0
    @objc dynamic var isLikedByMe: Bool = false

    override static func primaryKey() -> String? {
        return "id"
    }
}
