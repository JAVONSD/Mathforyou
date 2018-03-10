//
//  RequestObject.swift
//  Life
//
//  Created by Shyngys Kassymov on 10.03.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import RealmSwift

class RequestObject: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var surname: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var taskNumber: String = ""
    @objc dynamic var registrationDate: String = ""
    @objc dynamic var dateofdelivery: String = ""
    @objc dynamic var taskStatus: String = ""
    @objc dynamic var shortDescription: String = ""
    @objc dynamic var customer: String = ""
    @objc dynamic var comment: String = ""
    @objc dynamic var fullname: String = ""
    @objc dynamic var topic: String = ""
    @objc dynamic var executorName: String = ""
    @objc dynamic var authorName: String = ""
    @objc dynamic var isExpired: Bool = false
    @objc dynamic var isRequest: Bool = false
    @objc dynamic var endDate: String = ""
    @objc dynamic var statusCode: Int = Request.Status.new.rawValue

    override static func primaryKey() -> String? {
        return "id"
    }
}
