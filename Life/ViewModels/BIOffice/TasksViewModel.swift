//
//  TasksViewModel.swift
//  Life
//
//  Created by Shyngys Kassymov on 19.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import IGListKit
import Moya
import RxSwift

class TasksViewModel: NSObject, ListDiffable {

    var inboxTasks = [TaskViewModel]()
    var outboxTasks = [TaskViewModel]()

    var tasks: [TaskViewModel] {
        return inboxTasks + outboxTasks
    }

    private(set) var loading = false
    private(set) var canLoadMore = true

    private let disposeBag = DisposeBag()

    private let provider = MoyaProvider<TasksService>(
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
            .request(.inboxTasks)
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                self.loading = false
                self.canLoadMore = false

                switch response {
                case .success(let json):
                    if let taskItems = try? JSONDecoder().decode([Task].self, from: json.data) {
                        let items = taskItems.map { TaskViewModel(task: $0) }
                        self.inboxTasks = items

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
            .request(.outboxTasks)
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                self.loading = false
                self.canLoadMore = false

                switch response {
                case .success(let json):
                    if let taskItems = try? JSONDecoder().decode([Task].self, from: json.data) {
                        let items = taskItems.map { TaskViewModel(task: $0) }
                        self.outboxTasks = items

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

    public func createTask(
        executorCode: String,
        topic: String,
        description: String,
        isAllDay: Bool = false,
        location: String = "",
        startDateTime: String = "",
        endDateTime: String = "",
        reminder: Int = 0,
        participants: [String] = [],
        type: Task.TaskType = .execute,
        attachments: [URL] = [],
        completion: @escaping ((Task?, Error?) -> Void)) {
        provider
            .rx
            .request(.createTask(
                executorCode: executorCode,
                topic: topic,
                description: description,
                isAllDay: isAllDay,
                location: location,
                startDateTime: startDateTime,
                endDateTime: endDateTime,
                reminder: reminder,
                participants: participants,
                type: type.rawValue,
                attachments: attachments
                ))
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                switch response {
                case .success(let json):
                    if let task = try? JSONDecoder().decode(Task.self, from: json.data) {
                        completion(task, nil)
                    } else {
                        completion(nil, nil)
                    }
                case .error(let error):
                    completion(nil, error)
                }
            }
            .disposed(by: disposeBag)
    }

    public func updateTask(
        to task: Task,
        completion: @escaping ((Task?, Error?) -> Void)) {
        provider
            .rx
            .request(.updateTask(task: task))
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                switch response {
                case .success(let json):
                    if let task = try? JSONDecoder().decode(Task.self, from: json.data) {
                        completion(task, nil)
                    } else {
                        completion(nil, nil)
                    }
                case .error(let error):
                    completion(nil, error)
                }
            }
            .disposed(by: disposeBag)
    }

    public func addMessage(
        text: String,
        taskId: String,
        completion: @escaping ((Message?, Error?) -> Void)) {
        provider
            .rx
            .request(.addMessage(text: text, taskId: taskId))
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                switch response {
                case .success(let json):
                    if let message = try? JSONDecoder().decode(Message.self, from: json.data) {
                        completion(message, nil)
                    } else {
                        completion(nil, nil)
                    }
                case .error(let error):
                    completion(nil, error)
                }
            }
            .disposed(by: disposeBag)
    }

    // MARK: - ListDiffable

    func diffIdentifier() -> NSObjectProtocol {
        return self
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let object = object as? TasksViewModel {
            return self == object
        }
        return false
    }
}

extension TasksViewModel: Mockable {
    typealias T = TasksViewModel

    static func sample() -> TasksViewModel {
        let sample = TasksViewModel()

        for _ in 0..<3 {
            let json1 = [
                "topic": "Test inbox task",
                "endDate": "2018-02-21T10:00:30.563"
            ]
            if let task = try? JSONDecoder().decode(Task.self, from: json1.toJSONData()) {
                sample.inboxTasks.append(TaskViewModel(task: task))
            }

            let json2 = [
                "topic": "Test outobx task",
                "endDate": "2018-02-21T10:00:30.563"
            ]
            if let task = try? JSONDecoder().decode(Task.self, from: json2.toJSONData()) {
                sample.outboxTasks.append(TaskViewModel(task: task))
            }
        }

        return sample
    }
}

class TaskViewModel: NSObject, ListDiffable {
    var task: Task

    init(task: Task) {
        self.task = task
    }

    func diffIdentifier() -> NSObjectProtocol {
        return NSString(string: task.id)
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let item = object as? TaskViewModel {
            return task.id == item.task.id
        }
        return false
    }
}
