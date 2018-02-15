//
//  Response+Extensions.swift
//  Life
//
//  Created by Shyngys Kassymov on 15.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import Moya

enum ResponseError: Error {

    case badRequest(message: [String: String])
    case unathorized(message: [String: String])
    case timeOut(message: [String: String])
    case serverError(message: [String: String])
    case other(message: [String: String])

    var message: [String: String] {
        switch self {
        case .badRequest(let text):
            return text
        case .unathorized(let text):
            return text
        case .timeOut(let text):
            return text
        case .serverError(let text):
            return text
        case .other(let text):
            return text
        }
    }

}

extension Response {

    fileprivate func badRequest(_ errorMessages: inout [String : String]) -> ResponseError {
        let defaultMessage = NSLocalizedString("bad_requet_error_message", comment: "")
        if errorMessages.isEmpty {
            errorMessages["error"] = defaultMessage
        }

        return .badRequest(message: errorMessages)
    }

    fileprivate func unauthorized(_ errorMessages: inout [String : String]) -> ResponseError {
        let defaultMessage = NSLocalizedString("unathorized_error_message", comment: "")
        if errorMessages.isEmpty {
            errorMessages["error"] = defaultMessage
        }

        return .unathorized(message: errorMessages)
    }

    fileprivate func timeout(_ errorMessages: inout [String : String]) -> ResponseError {
        let defaultMessage = NSLocalizedString("time_out_error_message", comment: "")
        if errorMessages.isEmpty {
            errorMessages["error"] = defaultMessage
        }

        return .timeOut(message: errorMessages)
    }

    fileprivate func serverError(_ errorMessages: inout [String : String]) -> ResponseError {
        let defaultMessage = NSLocalizedString("server_error_message", comment: "")
        if errorMessages.isEmpty {
            errorMessages["error"] = defaultMessage
        }

        return .serverError(message: errorMessages)
    }

    fileprivate func other(_ errorMessages: inout [String : String]) -> ResponseError {
        let defaultMessage = NSLocalizedString("default_network_error", comment: "")
        if errorMessages.isEmpty {
            errorMessages["error"] = defaultMessage
        }

        return .other(message: errorMessages)
    }

    func parseError() -> ResponseError {
        var errorMessages = [String: String]()

        if let json = try? mapJSON(),
            let dict = json as? [String: Any?] {
            parseMessage(from: dict, to: &errorMessages)
        }

        switch statusCode {
        case 400:
            return badRequest(&errorMessages)
        case 401:
            return unauthorized(&errorMessages)
        case 408:
            return timeout(&errorMessages)
        case 500:
            return serverError(&errorMessages)
        default:
            return other(&errorMessages)
        }
    }

    private func parseMessage(
        from dict: [String: Any?],
        to errors: inout [String: String]) {
        for (key, value) in dict {
            if let strValue = value as? String {
                errors[key] = strValue
            } else if let arrValue = value as? [String] {
                errors[key] = arrValue.joined(separator: "\n")
            }
        }
    }

}
