//
//  AuthService.swift
//  Life
//
//  Created by Shyngys Kassymov on 14.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import Moya

enum AuthService {
    case auth
    case token(login: String, password: String)
    case testtokenauth
}

extension AuthService: AuthorizedTargetType {

    var path: String {
        switch self {
        case .auth:
            return "/auth"
        case .token:
            return "/token"
        case .testtokenauth:
            return "/testtokenauth"
        }
    }

    var method: Moya.Method {
        switch self {
        case .auth, .testtokenauth:
            return .get
        case .token:
            return .post
        }
    }

    var task: Task {
        switch self {
        case .auth, .testtokenauth:
            return .requestPlain
        case let .token(login, password):
            return .requestParameters(
                parameters: ["login": login, "password": password],
                encoding: JSONEncoding.default
            )
        }
    }

    var sampleData: Data {
        switch self {
        case .auth:
            return Bundle.main.stubJSONWith(name: "auth")
        case .token:
            return Bundle.main.stubJSONWith(name: "token")
        case .testtokenauth:
            return Bundle.main.stubJSONWith(name: "testtokenauth")
        }
    }

    var headers: [String: String]? {
        switch self {
        case .token:
            return ["Content-type": "application/json"]
        default:
            return nil
        }
    }

    var needsAuth: Bool {
        switch self {
        case .token:
            return false
        default:
            return true
        }
    }

}

class TokenSource {
    var token: String?
    init() {}
}

protocol AuthorizedTargetType: TargetType {
    var needsAuth: Bool { get }
}

extension AuthorizedTargetType {
    var baseURL: URL { return URL(string: "http://life.bi-group.org:8090/api")! }
}

struct AuthPlugin: PluginType {
    let tokenClosure: () -> String?

    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        guard
            let token = tokenClosure(),
            let target = target as? AuthorizedTargetType,
            target.needsAuth
            else {
                return request
        }

        var request = request
        request.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        return request
    }
}
