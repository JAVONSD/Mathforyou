//
//  CommentObject.swift
//  Life
//
//  Created by Shyngys Kassymov on 10.03.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import RealmSwift

class CommentObject: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var authorCode: String = ""
    @objc dynamic var authorName: String = ""
    @objc dynamic var createDate: String = ""
    @objc dynamic var text: String = ""
    @objc dynamic var likesQuantity: Int = 0
    @objc dynamic var dislikesQuantity: Int = 0
    let userVote = RealmOptional<Int>()
    let vote = RealmOptional<Int>()
    @objc dynamic var type: Int = 0

    override static func primaryKey() -> String? {
        return "id"
    }
}
