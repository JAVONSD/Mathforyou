//
//  RequestsViewModel.swift
//  Life
//
//  Created by Shyngys Kassymov on 19.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import IGListKit
import Moya
import RxSwift

class RequestsViewModel: NSObject, ListDiffable {

    var inboxRequests = [RequestViewModel]()
    var outboxRequests = [RequestViewModel]()

    var requests: [RequestViewModel] {
        return inboxRequests + outboxRequests
    }

    private(set) var loadingInboxRequests = false
    private(set) var canLoadMoreInboxRequests = true

    private(set) var loadingOutboxRequests = false
    private(set) var canLoadMoreOutboxRequests = true

    private let disposeBag = DisposeBag()

    private let provider = MoyaProvider<RequestsService>(
        plugins: [
            AuthPlugin(tokenClosure: {
                return User.current.token
            })
        ]
    )

    // MARK: - Methods

    public func getInbox(completion: @escaping ((Error?) -> Void)) {
        provider
            .rx
            .request(.inboxRequests)
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                self.loadingInboxRequests = false
                self.canLoadMoreInboxRequests = false

                switch response {
                case .success(let json):
                    if let requestItems = try? JSONDecoder().decode([Request].self, from: json.data) {
                        let items = requestItems.map { RequestViewModel(request: $0) }
                        self.inboxRequests = items

                        completion(nil)
                    } else {
                        completion(nil)
                    }
                case .error(let error):
                    completion(error)
                }
            }
            .disposed(by: disposeBag)
    }

    public func getOutbox(completion: @escaping ((Error?) -> Void)) {
        provider
            .rx
            .request(.outboxRequests)
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                self.loadingOutboxRequests = false
                self.canLoadMoreOutboxRequests = false

                switch response {
                case .success(let json):
                    if let requestItems = try? JSONDecoder().decode([Request].self, from: json.data) {
                        let items = requestItems.map { RequestViewModel(request: $0) }
                        self.outboxRequests = items

                        completion(nil)
                    } else {
                        completion(nil)
                    }
                case .error(let error):
                    completion(error)
                }
            }
            .disposed(by: disposeBag)
    }

    public func createRequest(
        dueDate: String,
        description: String,
        attachments: [URL],
        completion: @escaping ((Error?) -> Void)) {
        provider
            .rx
            .request(.createRequest(
                dueDate: dueDate,
                description: description,
                attachments: attachments
                ))
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                switch response {
                case .success:
                    completion(nil)
                case .error(let error):
                    completion(error)
                }
            }
            .disposed(by: disposeBag)
    }

    // MARK: - ListDiffable

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
