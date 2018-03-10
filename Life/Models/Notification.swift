//
//  Notification.swift
//  Life
//
//  Created by Shyngys Kassymov on 24.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation

struct Notification: Codable, Hashable {

    enum NotificationType: Int, Codable {
        case onTaskCreated = 10
        case onQuestionnaireCreated = 20
        case onTaskStatusChanged = 30
        case onTaskExecutorChanged = 31
        case onTaskDueDateChanged = 32
        case onSuggestionCreated = 40
    }

    var id = UUID().uuidString
    var message = ""
    var eventType = NotificationType.onTaskCreated
    var authorCode = ""
    var authorName = ""
    var createDate = ""
    var entityId = ""

    // MARK: - Hashable

    var hashValue: Int {
        return id.hashValue
    }

    static func == (lhs: Notification, rhs: Notification) -> Bool {
        return lhs.id == rhs.id
    }

}

// MARK: - Persistable

extension Notification: Persistable {
    init(managedObject: NotificationObject) {
        id = managedObject.id
        message = managedObject.message
        eventType = NotificationType(rawValue: managedObject.eventType) ?? .onTaskCreated
        authorCode = managedObject.authorCode
        authorName = managedObject.authorName
        createDate = managedObject.createDate
        entityId = managedObject.entityId
    }

    func managedObject() -> NotificationObject {
        let object = NotificationObject()
        object.id = id
        object.message = message
        object.eventType = eventType.rawValue
        object.authorCode = authorCode
        object.authorName = authorName
        object.createDate = createDate
        object.entityId = entityId
        return object
    }
}
