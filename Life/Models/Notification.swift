//
//  Notification.swift
//  Life
//
//  Created by Shyngys Kassymov on 24.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation

struct Notification: Codable {

    enum `Type`: Int, Codable {
        case onTaskCreated = 10
        case onQuestionnaireCreated = 20
        case onTaskStatusChanged = 30
        case onTaskExecutorChanged = 31
        case onTaskDueDateChanged = 32
        case onSuggestionCreated = 40
    }

    var id = UUID().uuidString
    var message = ""
    var eventType = Type.onTaskCreated
    var authorCode = ""
    var authorName = ""
    var createDate = ""
    var entityId = ""
}
