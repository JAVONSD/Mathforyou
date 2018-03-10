//
//  RequestsViewModel.swift
//  Life
//
//  Created by Shyngys Kassymov on 19.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import IGListKit
import DateToolsSwift
import Moya
import RxSwift

class RequestsViewModel: NSObject, ListDiffable {

    private(set) var inboxRequests = [RequestViewModel]()
    private(set) var outboxRequests = [RequestViewModel]()

    let inboxRequestsSubject = PublishSubject<[RequestViewModel]>()
    let outboxRequestsSubject = PublishSubject<[RequestViewModel]>()
    let allRequestsSubject = PublishSubject<[RequestViewModel]>()
    let requestCreatedSubject = PublishSubject<Bool>()

    var requests: [RequestViewModel] {
        let items = inboxRequests + outboxRequests
        return items.sorted(by: { (item1, item2) -> Bool in
            let date1 = item1.request.registrationDate.date
            let date2 = item2.request.registrationDate.date
            return date1.isLater(than: date2)
        })
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
        returnRequestsFromCache(completion: completion, isInbox: true)

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
                        self.inboxRequestsSubject.onNext(items)

                        self.updateRequestsCache(requestItems, isInbox: true)
                    } else {
                        completion(nil)
                        self.inboxRequestsSubject.onNext(self.inboxRequests)
                    }
                    self.allRequestsSubject.onNext(self.requests)
                case .error(let error):
                    completion(error)
                    self.inboxRequestsSubject.onNext(self.inboxRequests)
                    self.allRequestsSubject.onNext(self.requests)
                }
            }
            .disposed(by: disposeBag)
    }

    public func getOutbox(completion: @escaping ((Error?) -> Void)) {
        returnRequestsFromCache(completion: completion, isInbox: false)

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
                        self.outboxRequestsSubject.onNext(items)

                        self.updateRequestsCache(requestItems, isInbox: false)
                    } else {
                        completion(nil)
                        self.outboxRequestsSubject.onNext(self.outboxRequests)
                    }
                    self.allRequestsSubject.onNext(self.requests)
                case .error(let error):
                    completion(error)
                    self.outboxRequestsSubject.onNext(self.outboxRequests)
                    self.allRequestsSubject.onNext(self.requests)
                }
            }
            .disposed(by: disposeBag)
    }

    private func returnRequestsFromCache(completion: @escaping ((Error?) -> Void), isInbox: Bool) {
        DispatchQueue.global().async {
            do {
                let realm = isInbox
                    ? try App.Realms.inboxTasksAndRequests()
                    : try App.Realms.outboxTasksAndRequests()
                let cachedRequestObjects = realm.objects(RequestObject.self)

                let cachedRequests = cachedRequestObjects.map { Request(managedObject: $0) }
                let items = Array(cachedRequests).map { RequestViewModel(request: $0) }

                if isInbox {
                    self.inboxRequests = items
                } else {
                    self.outboxRequests = items
                }

                completion(nil)

                DispatchQueue.main.async {
                    if isInbox {
                        self.inboxRequestsSubject.onNext(items)
                    } else {
                        self.outboxRequestsSubject.onNext(items)
                    }
                }
            } catch let error as NSError {
                print("Failed to access the Realm database with error - \(error.localizedDescription)")
            }
        }
    }

    private func updateRequestsCache(_ requestItems: [Request], isInbox: Bool) {
        DispatchQueue.global().async {
            do {
                let realm = isInbox
                    ? try App.Realms.inboxTasksAndRequests()
                    : try App.Realms.outboxTasksAndRequests()
                realm.beginWrite()
                for request in requestItems {
                    realm.add(request.managedObject(), update: true)
                }
                for requestObject in realm.objects(RequestObject.self).reversed() {
                    if !requestItems.contains(Request(managedObject: requestObject)),
                        let requestObjectToDelete = realm.object(
                            ofType: RequestObject.self,
                            forPrimaryKey: requestObject.id) {
                        realm.delete(requestObjectToDelete)
                    }
                }
                try realm.commitWrite()
            } catch {
                print("Failed to access the Realm database")
            }
        }
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

                    self.requestCreatedSubject.onNext(true)
                case .error(let error):
                    completion(error)

                    self.requestCreatedSubject.onNext(false)
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
