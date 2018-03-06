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

    let isLoadingSubject = PublishSubject<Bool>()
    let errorSubject = PublishSubject<Error>()

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
                self.isLoadingSubject.onNext(false)
                self.tasksAndRequestsSubject.onNext(items)
            }.disposed(by: disposeBag)
    }

    // MARK: - Methods

    public func getAllTasksAndRequests() {
        bind()

        isLoadingSubject.onNext(true)

        getAllTasks()
        getAllRequests()
    }

    public func getAllTasks() {
        tasks.getInbox { error in
            guard let error = error else { return }
            self.errorSubject.onNext(error)
        }

        tasks.getOutbox { error in
            guard let error = error else { return }
            self.errorSubject.onNext(error)
        }
    }

    public func getAllRequests() {
        requests.getInbox { error in
            guard let error = error else { return }
            self.errorSubject.onNext(error)
        }

        requests.getOutbox { error in
            guard let error = error else { return }
            self.errorSubject.onNext(error)
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

extension TasksAndRequestsViewModel: Stepper {
    public func createNewRequest(category: Request.Category, didCreateRequest: @escaping (() -> Void)) {
        self.step.accept(AppStep.createRequest(category: category, didCreateRequest: didCreateRequest))
    }

    public func createNewTask(didCreateTask: @escaping (() -> Void)) {
        self.step.accept(AppStep.createTask(didCreateTask: didCreateTask))
    }
}
