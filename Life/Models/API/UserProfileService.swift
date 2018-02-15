//
//  UserProfileService.swift
//  Life
//
//  Created by Shyngys Kassymov on 14.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import Moya

enum UserProfileService {
    case userProfile
}

extension UserProfileService: AuthorizedTargetType {

    var path: String {
        switch self {
        case .userProfile:
            return "/UserProfile"
        }
    }

    var method: Moya.Method {
        switch self {
        case .userProfile:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .userProfile:
            return .requestPlain
        }
    }

    var sampleData: Data {
        switch self {
        case .userProfile:
            return Bundle.main.stubJSONWith(name: "user_profile")
        }
    }

    var headers: [String: String]? {
        return nil
    }

    var needsAuth: Bool {
        return true
    }

}
