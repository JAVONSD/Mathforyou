//
//  TagObject.swift
//  Life
//
//  Created by Shyngys Kassymov on 10.03.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import RealmSwift

class TagObject: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var nsiTagId: String = ""
    @objc dynamic var name: String = ""

    override static func primaryKey() -> String? {
        return "id"
    }
}
