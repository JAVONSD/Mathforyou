//
//  LentaService.swift
//  Life
//
//  Created by Shyngys Kassymov on 14.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import Moya

enum LentaService {
    case lenta(rows: Int, offset: Int, withDescription: Bool)
}

extension LentaService: AuthorizedTargetType {

    var path: String {
        switch self {
        case .lenta:
            return "/Lenta"
        }
    }

    var method: Moya.Method {
        switch self {
        case .lenta:
            return .get
        }
    }

    var task: Moya.Task {
        switch self {
        case let .lenta(rows, offset, withDescription):
            return .requestParameters(
                parameters: [
                    "rows": rows,
                    "offset": offset,
                    "withDescription": withDescription
                ],
                encoding: URLEncoding.default
            )
        }
    }

    var sampleData: Data {
        switch self {
        case .lenta:
            return Bundle.main.stubJSONWith(name: "lenta")
        }
    }

    var headers: [String: String]? {
        switch self {
        default:
            return nil
        }
    }

    var needsAuth: Bool {
        return true
    }

}
