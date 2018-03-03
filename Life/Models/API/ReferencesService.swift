//
//  ReferencesService.swift
//  Life
//
//  Created by Shyngys Kassymov on 14.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import Moya

enum ReferencesService {
    case tags
    case systems
}

extension ReferencesService: AuthorizedTargetType {

    var path: String {
        switch self {
        case .tags:
            return "/tags"
        case .systems:
            return "/systems"
        }
    }

    var method: Moya.Method {
        switch self {
        case .tags, .systems:
            return .get
        }
    }

    var task: Moya.Task {
        switch self {
        case .tags, .systems:
            return .requestPlain
        }
    }

    var sampleData: Data {
        switch self {
        case .tags:
            return Bundle.main.stubJSONWith(name: "tags")
        case .systems:
            return Bundle.main.stubJSONWith(name: "systems")
        }
    }

    var headers: [String: String]? {
        return nil
    }

    var needsAuth: Bool {
        return true
    }

}
