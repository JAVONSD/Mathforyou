//
//  EventsService.swift
//  Life
//
//  Created by Shyngys Kassymov on 14.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import Moya

enum EventsService {
    case history
    case mine(start: Date, end: Date)
    case company
}

extension EventsService: AuthorizedTargetType {

    var path: String {
        switch self {
        case .history:
            return "/Events/history"
        case .mine:
            return "/Events/mine"
        case .company:
            return "/Events/company"
        }
    }

    var method: Moya.Method {
        switch self {
        case .history,
             .mine,
             .company:
            return .get
        }
    }

    var task: Moya.Task {
        switch self {
        case .history,
             .company:
            return .requestPlain
        case let .mine(start, end):
            return .requestParameters(
                parameters: [
                    "start": start.serverDate,
                    "end": end.serverDate
                ],
                encoding: URLEncoding.default
            )
        }
    }

    var sampleData: Data {
        switch self {
        case .history:
            return Bundle.main.stubJSONWith(name: "history")
        case .mine:
            return Bundle.main.stubJSONWith(name: "mine")
        case .company:
            return Bundle.main.stubJSONWith(name: "company")
        }
    }

    var headers: [String: String]? {
        return nil
    }

    var needsAuth: Bool {
        return true
    }

}
