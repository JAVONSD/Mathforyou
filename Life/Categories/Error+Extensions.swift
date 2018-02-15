//
//  Error+Extensions.swift
//  Life
//
//  Created by Shyngys Kassymov on 15.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import Moya

extension Error {

    func parseMessages() -> [String: String] {
        var errorMessages = [String: String]()

        if let moyaError = self as? MoyaError {
            switch moyaError {
            case .statusCode(let response):
                let responseError = response.parseError()
                errorMessages = responseError.message
            default:
                break
            }
        }

        return errorMessages
    }

}
