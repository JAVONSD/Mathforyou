//
//  EmployeesService.swift
//  Life
//
//  Created by Shyngys Kassymov on 14.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import Moya

enum EmployeesService {
    case employees
    case search(text: String, top: Int)
    case employeeInfo(code: String)
    case vacancies
    case birthdays
    case congratulate(code: String, text: String)
}

extension EmployeesService: AuthorizedTargetType {

    var path: String {
        switch self {
        case .employees:
            return "/employees"
        case .search:
            return "/employees/search"
        case .employeeInfo(let code):
            return "/employees/" + code
        case .vacancies:
            return "/vacancies"
        case .birthdays:
            return "/employeesEvents"
        case .congratulate(let code, _):
            return "/employees/\(code)/congratulations"
        }
    }

    var method: Moya.Method {
        switch self {
        case .employees,
             .search,
             .employeeInfo,
             .vacancies,
             .birthdays:
            return .get
        case .congratulate:
            return .post
        }
    }

    var task: Moya.Task {
        switch self {
        case .employees,
             .employeeInfo,
             .vacancies,
             .birthdays:
            return .requestPlain
        case let .search(text, top):
            return .requestParameters(
                parameters: ["filterText": text, "top": top],
                encoding: URLEncoding.default
            )
        case let .congratulate(_, text):
            return .requestParameters(
                parameters: ["congratulationText": text],
                encoding: JSONEncoding.default
            )
        }
    }

    var sampleData: Data {
        switch self {
        case .employees:
            return Bundle.main.stubJSONWith(name: "employees")
        case .search:
            return Bundle.main.stubJSONWith(name: "employees_search")
        case .employeeInfo:
            return Bundle.main.stubJSONWith(name: "employee_info")
        case .vacancies:
            return Bundle.main.stubJSONWith(name: "vacancies")
        case .birthdays:
            return Bundle.main.stubJSONWith(name: "birthdays")
        case .congratulate:
            return "{\"status\": 200}".utf8Encoded
        }
    }

    var headers: [String: String]? {
        return nil
    }

    var needsAuth: Bool {
        return true
    }

}
