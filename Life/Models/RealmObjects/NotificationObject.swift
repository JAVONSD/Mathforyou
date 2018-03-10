//
//  NotificationObject.swift
//  Life
//
//  Created by Shyngys Kassymov on 10.03.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import RealmSwift

class NotificationObject: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var message: String = ""
    @objc dynamic var eventType: Int = Notification.NotificationType.onTaskCreated.rawValue
    @objc dynamic var authorCode: String = ""
    @objc dynamic var authorName: String = ""
    @objc dynamic var createDate: String = ""
    @objc dynamic var entityId: String = ""

    override static func primaryKey() -> String? {
        return "id"
    }
}
