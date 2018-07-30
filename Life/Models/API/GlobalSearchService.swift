//
//  GlobalSearchService.swift
//  Life
//
//  Created by 123 on 25.07.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import Moya

enum GlobalSearchService {
    case globalSearch(searchTxt: String, rows: Int, offset: Int, entityType: Int, isMobile: Bool)
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
        case let .globalSearch(searchTxt, rows, offset, entityType, isMobile):
            return .requestParameters(
                parameters: ["searchTxt": searchTxt,
                             "rows": rows,
                             "offset": offset,
                             "entityType": entityType,
                             "isMobile": isMobile],
                encoding: URLEncoding.default
            )
        }
    }
    
    var sampleData: Data {
        switch self {
        case .globalSearch:
            // TO DO - make for global search
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







