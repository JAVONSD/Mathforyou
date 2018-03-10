//
//  TaskObject.swift
//  Life
//
//  Created by Shyngys Kassymov on 10.03.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import RealmSwift

class TaskObject: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var topic: String = ""
    @objc dynamic var authorCode: String = ""
    @objc dynamic var authorName: String = ""
    @objc dynamic var isAllDay: Bool = false
    @objc dynamic var startDate: String?
    @objc dynamic var endDate: String?
    @objc dynamic var location: String?
    @objc dynamic var statusCode: Int = Task.Status.new.rawValue
    @objc dynamic var isExpired: Bool = false
    @objc dynamic var descriptionText: String = ""
    @objc dynamic var executorCode: String = ""
    @objc dynamic var executorName: String = ""
    @objc dynamic var reminder: Int = 0
    @objc dynamic var type: Int = Task.TaskType.execute.rawValue
    @objc dynamic var approveEntityId: String = ""
    @objc dynamic var approveEntityType: String = ""
    @objc dynamic var label: String = ""
    let participants = List<EmployeeObject>()
    let messages = List<MessageObject>()
    let attachments = List<String>()
    let actions = List<TaskActionObject>()

    override static func primaryKey() -> String? {
        return "id"
    }
}
