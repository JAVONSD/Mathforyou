//
//  NotificationsService.swift
//  Life
//
//  Created by Shyngys Kassymov on 14.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import Moya

enum NotificationsService {
    case notifications
    case readNotification(id: String)
}

extension NotificationsService: AuthorizedTargetType {

    var path: String {
        switch self {
        case .notifications:
            return "/Notifications"
        case .readNotification(let id):
            return "/Notifications/\(id)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .notifications:
            return .get
        case .readNotification:
            return .put
        }
    }

    var task: Moya.Task {
        switch self {
        case .notifications, .readNotification:
            return .requestPlain
        }
    }

    var sampleData: Data {
        switch self {
        case .notifications:
            return Bundle.main.stubJSONWith(name: "notifications")
        case .readNotification:
            return [:].toJSONData()
        }
    }

    var headers: [String: String]? {
        return nil
    }

    var needsAuth: Bool {
        return true
    }

}
