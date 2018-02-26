//
//  RequestsService.swift
//  Life
//
//  Created by Shyngys Kassymov on 14.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import Moya

enum RequestsService {
    case inboxRequests
    case outboxRequests
    case createRequest(
        dueDate: String,
        description: String,
        attachments: [URL]
    )
}

extension RequestsService: AuthorizedTargetType {

    var path: String {
        switch self {
        case .inboxRequests:
            return "/Requests/servicedesk/inbox"
        case .outboxRequests:
            return "/Requests/servicedesk/outbox"
        case .createRequest:
            return "/Requests"
        }
    }

    var method: Moya.Method {
        switch self {
        case .inboxRequests, .outboxRequests:
            return .get
        case .createRequest:
            return .post
        }
    }

    var task: Moya.Task {
        switch self {
        case .inboxRequests, .outboxRequests:
            return .requestPlain
        case .createRequest(let dueDate, let description, let attachments):
            var data = [MultipartFormData]()

            let dueDateData = MultipartFormData(
                provider: .data(dueDate.utf8Encoded),
                name: "DueDate"
            )
            data.append(dueDateData)

            let descriptionData = MultipartFormData(
                provider: .data(description.utf8Encoded),
                name: "Description"
            )
            data.append(descriptionData)

            for attachment in attachments {
                let attachmentsData = MultipartFormData(
                    provider: .file(attachment),
                    name: "Attachments"
                )
                data.append(attachmentsData)
            }

            return .uploadMultipart(data)
        }
    }

    var sampleData: Data {
        switch self {
        case .inboxRequests, .outboxRequests:
            return Bundle.main.stubJSONWith(name: "requests")
        case .createRequest:
            return "{\"statusCode\": 200}".utf8Encoded
        }
    }

    var headers: [String: String]? {
        return nil
    }

    var needsAuth: Bool {
        return true
    }

}
