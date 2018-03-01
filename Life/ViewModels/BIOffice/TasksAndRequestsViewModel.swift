//
//  TasksAndRequestsViewModel.swift
//  Life
//
//  Created by Shyngys Kassymov on 19.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import IGListKit
import Moya
import RxSwift

class TasksAndRequestsViewModel: NSObject, ViewModel, ListDiffable {
    private(set) var tasks = TasksViewModel()
    private(set) var requests = RequestsViewModel()

    private let disposeBag = DisposeBag()
    let tasksAndRequestsSubject = PublishSubject<[ListDiffable]>()
    private var tasksAndRequestsObservable: Observable<[ListDiffable]>?

    var onUnathorizedError: (() -> Void)?

    var minimized = true

    enum SelectedItemsType {
        case inbox, outbox
    }

    var selectedItemsType = SelectedItemsType.inbox

    var items: [ListDiffable] {
        var allItems = [ListDiffable]()
        allItems.append(contentsOf: tasks.tasks as [ListDiffable])
        allItems.append(contentsOf: requests.requests as [ListDiffable])
        return allItems
    }

    var currentItems: [ListDiffable] {
        if selectedItemsType == .outbox {
            return outboxItems
        }
        return inboxItems
    }

    var inboxItems: [ListDiffable] {
        return (tasks.inboxTasks as [ListDiffable]) + (requests.inboxRequests as [ListDiffable])
    }

    var outboxItems: [ListDiffable] {
        return (tasks.outboxTasks as [ListDiffable]) + (requests.outboxRequests as [ListDiffable])
    }

    var inboxCount: Int {
        return tasks.inboxTasks.count + requests.inboxRequests.count
    }

    var outboxCount: Int {
        return tasks.outboxTasks.count + requests.outboxRequests.count
    }

    // MARK: - Bind

    private func bind() {
        let tasksInboxObservable = tasks.inboxTasksSubject.asObservable()
        let tasksOutboxObservable = tasks.outboxTasksSubject.asObservable()
        let requestsInboxObservable = requests.inboxRequestsSubject.asObservable()
        let requestsOutboxObservable = requests.outboxRequestsSubject.asObservable()

        tasksAndRequestsObservable = Observable.zip(
            tasksInboxObservable,
            tasksOutboxObservable,
            requestsInboxObservable,
            requestsOutboxObservable
        ) { (inboxTasks, outboxTasks, inboxRequests, outboxRequests) -> [ListDiffable] in
            var allItems = [ListDiffable]()
            allItems.append(contentsOf: inboxTasks as [ListDiffable])
            allItems.append(contentsOf: outboxTasks as [ListDiffable])
            allItems.append(contentsOf: inboxRequests as [ListDiffable])
            allItems.append(contentsOf: outboxRequests as [ListDiffable])
            return allItems
            }
        tasksAndRequestsObservable?
            .bind { (items) in
                self.tasksAndRequestsSubject.onNext(items)
            }.disposed(by: disposeBag)
    }

    // MARK: - Methods

    public func getAllTasksAndRequests() {
        bind()

        tasks.getInbox { error in
            if let moyaError = error as? MoyaError,
                moyaError.response?.statusCode == 401,
                let onUnathorizedError = self.onUnathorizedError {
                onUnathorizedError()
            }
        }

        tasks.getOutbox { error in
            if let moyaError = error as? MoyaError,
                moyaError.response?.statusCode == 401,
                let onUnathorizedError = self.onUnathorizedError {
                onUnathorizedError()
            }
        }

        requests.getInbox { error in
            if let moyaError = error as? MoyaError,
                moyaError.response?.statusCode == 401,
                let onUnathorizedError = self.onUnathorizedError {
                onUnathorizedError()
            }
        }

        requests.getOutbox { error in
            if let moyaError = error as? MoyaError,
                moyaError.response?.statusCode == 401,
                let onUnathorizedError = self.onUnathorizedError {
                onUnathorizedError()
            }
        }
    }

    // MARK: - ListDiffable

    func diffIdentifier() -> NSObjectProtocol {
        return self
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let object = object as? TasksAndRequestsViewModel {
            return self == object
        }
        return false
    }
}

extension TasksAndRequestsViewModel: Mockable {
    typealias T = TasksAndRequestsViewModel

    static func sample() -> TasksAndRequestsViewModel {
        let sample = TasksAndRequestsViewModel()

        sample.tasks = TasksViewModel.sample()
        sample.requests = RequestsViewModel.sample()

        return sample
    }
}
