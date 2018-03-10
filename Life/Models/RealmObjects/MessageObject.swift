//
//  MessageObject.swift
//  Life
//
//  Created by Shyngys Kassymov on 10.03.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import RealmSwift

class MessageObject: Object {
    @objc dynamic var authorCode: String = ""
    @objc dynamic var authorName: String = ""
    @objc dynamic var message: String = ""
    @objc dynamic var createDate: String = ""
    @objc dynamic var isFromCurrentUser: Bool = false
}
