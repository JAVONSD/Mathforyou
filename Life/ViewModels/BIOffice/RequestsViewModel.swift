//
//  RequestsViewModel.swift
//  Life
//
//  Created by Shyngys Kassymov on 19.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import IGListKit

class RequestsViewModel: NSObject, ListDiffable {
    var requests = [RequestViewModel]()

    func diffIdentifier() -> NSObjectProtocol {
        return self
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let object = object as? RequestsViewModel {
            return self == object
        }
        return false
    }
}

extension RequestsViewModel: Mockable {
    typealias T = RequestsViewModel

    static func sample() -> RequestsViewModel {
        let sample = RequestsViewModel()

        for _ in 0..<3 {
            let json = [
                "topic": "Test request"
            ]
            if let request = try? JSONDecoder().decode(Request.self, from: json.toJSONData()) {
                sample.requests.append(RequestViewModel(request: request))
            }
        }

        return sample
    }
}

class RequestViewModel: NSObject, ListDiffable {
    var request: Request

    init(request: Request) {
        self.request = request
    }

    func diffIdentifier() -> NSObjectProtocol {
        return NSString(string: request.taskNumber)
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let item = object as? RequestViewModel {
            return request.taskNumber == item.request.taskNumber
        }
        return false
    }
}
