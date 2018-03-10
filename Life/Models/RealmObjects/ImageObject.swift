//
//  ImageObject.swift
//  Life
//
//  Created by Shyngys Kassymov on 10.03.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import RealmSwift

class ImageObject: Object {
    @objc dynamic var streamId: String = ""
    @objc dynamic var filename: String = ""

    override static func primaryKey() -> String? {
        return "streamId"
    }
}
