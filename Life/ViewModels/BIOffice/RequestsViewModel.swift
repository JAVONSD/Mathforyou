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

    var inboxRequests = [RequestViewModel]()
    var outboxRequests = [RequestViewModel]()

    var requests: [RequestViewModel] {
        return inboxRequests + outboxRequests
    }

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
            let json1 = [
                "topic": "Test inbox request"
            ]
            if let request = try? JSONDecoder().decode(Request.self, from: json1.toJSONData()) {
                sample.inboxRequests.append(RequestViewModel(request: request))
            }

            let json2 = [
                "topic": "Test outbox request"
            ]
            if let request = try? JSONDecoder().decode(Request.self, from: json2.toJSONData()) {
                sample.outboxRequests.append(RequestViewModel(request: request))
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
