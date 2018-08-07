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
    case errors(
        executor: String,
        description: String,
        attachments: [URL]
    )
}

extension UserProfileService: AuthorizedTargetType {

    var path: String {
        switch self {
        case .userProfile:
            return "/UserProfile"
        case .errors:
            return "/UserProfile/errors"
        }
    }

    var method: Moya.Method {
        switch self {
        case .userProfile:
            return .get
        case .errors:
            return .post
        }
    }

    var task: Moya.Task {
        switch self {
        case .userProfile:
            return .requestPlain
        case .errors(let executor, let description, let attachments):
            var data = [MultipartFormData]()

            for image in attachments {
                let imageData = image.multipartFormData("Attachments")
                data.append(imageData)
            }
            
            data.append(description.multipartFormData("Description"))
            data.append(executor.multipartFormData("Executor"))
            
            return .uploadMultipart(data)
        }
    }

    var sampleData: Data {
        switch self {
        case .userProfile:
            return Bundle.main.stubJSONWith(name: "user_profile")
        case .errors:
            return Bundle.main.stubJSONWith(name: "errors")
        }
    }

    var headers: [String: String]? {
        return nil
    }

    var needsAuth: Bool {
        return true
    }

}





