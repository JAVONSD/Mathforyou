//
//  TasksService.swift
//  Life
//
//  Created by Shyngys Kassymov on 14.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import Moya

enum TasksService {
    case inboxTasks
    case outboxTasks
    case createTask(
        executorCode: String,
        topic: String,
        description: String,
        isAllDay: Bool,
        location: String,
        startDateTime: String,
        endDateTime: String,
        reminder: Int,
        participants: [String],
        type: Int,
        attachments: [URL]
    )
    case updateTask(task: Task)
    case taskDetails(id: String)
    case addMessage(text: String, taskId: String)
}

extension TasksService: AuthorizedTargetType {

    var path: String {
        switch self {
        case .inboxTasks:
            return "/Tasks/inbox"
        case .outboxTasks:
            return "/Tasks/outbox"
        case .createTask:
            return "/Tasks"
        case .updateTask:
            return "/Tasks"
        case .taskDetails(let id):
            return "/Tasks/\(id)"
        case .addMessage(_, let taskId):
            return "/Tasks/\(taskId)/messages"
        }
    }

    var method: Moya.Method {
        switch self {
        case .inboxTasks, .outboxTasks, .taskDetails:
            return .get
        case .createTask, .addMessage:
            return .post
        case .updateTask:
            return .put
        }
    }

    var task: Moya.Task {
        switch self {
        case .inboxTasks, .outboxTasks, .taskDetails:
            return .requestPlain
        case .createTask(
            let executorCode,
            let topic,
            let description,
            let isAllDay,
            let location,
            let startDateTime,
            let endDateTime,
            let reminder,
            let participants,
            let type,
            let attachments
            ):
            var data = [MultipartFormData]()

            addStringData(executorCode, "ExecutorCode", &data)
            addStringData(topic, "Topic", &data)
            addStringData(description, "Description", &data)
            addStringData(String(isAllDay), "IsAllDay", &data)
            addStringData(location, "Location", &data)
            addStringData(startDateTime, "StartDateTime", &data)
            addStringData(endDateTime, "EndDateTime", &data)
            addStringData("\(reminder)", "Reminder", &data)
            addStringData("\(type)", "Type", &data)

            for participant in participants {
                addStringData(participant, "Participants", &data)
            }

            for attachment in attachments {
                let attachmentsData = attachment.multipartFormData("Attachments")
                data.append(attachmentsData)
            }

            return .uploadMultipart(data)
        case .updateTask(let task):
            var params = [String: Any]()
            if let data = try? JSONEncoder().encode(task),
                let dict = (try? JSONSerialization.jsonObject(
                    with: data, options: [])) as? [String: Any] {
                params = dict
            }
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .addMessage(let message, _):
            let params = ["message": message]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        }

    }

    var sampleData: Data {
        switch self {
        case .inboxTasks, .outboxTasks:
            return Bundle.main.stubJSONWith(name: "tasks")
        case .createTask, .taskDetails, .updateTask:
            return Bundle.main.stubJSONWith(name: "task")
        case .addMessage:
            return Bundle.main.stubJSONWith(name: "message")
        }
    }

    var headers: [String: String]? {
        return nil
    }

    var needsAuth: Bool {
        return true
    }

    // MARK: - Methods

    private func addStringData(
        _ data: String,
        _ name: String,
        _ formData: inout [MultipartFormData]) {
        let dueDateData = data.multipartFormData(name)
        formData.append(dueDateData)
    }

}
