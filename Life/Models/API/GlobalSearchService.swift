//
//  GlobalSearchService.swift
//  Life
//
//  Created by 123 on 25.07.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import Moya

            /// may be do not need it

enum GlobalSearchService {
    case globalSearch(searchTxt: String, rows: Int, offset: Int, entityType: Int)
}

extension GlobalSearchService: AuthorizedTargetType {

    var path: String {
        switch self {
        case .globalSearch:
            return "/GlobalSearch"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .globalSearch:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case let .globalSearch(searchTxt, rows, offset, entityType):
            return .requestParameters(
                parameters: ["searchTxt": searchTxt,
                             "rows": rows,
                             "offset": offset,
                             "entityType": entityType],
                encoding: URLEncoding.default
            )
        }
    }
    
    var sampleData: Data {
        switch self {
        case .globalSearch:
            return Bundle.main.stubJSONWith(name: "globalSearch")
        }
    }
    
    var needsAuth: Bool {
        return true
    }
    
    var headers: [String : String]? {
        return nil
    }
    
}







