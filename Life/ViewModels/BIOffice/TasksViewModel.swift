//
//  TasksViewModel.swift
//  Life
//
//  Created by Shyngys Kassymov on 19.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import IGListKit

class TasksViewModel: NSObject, ListDiffable {
    var tasks = [TaskViewModel]()

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
            let json = [
                "topic": "Test task"
            ]
            if let task = try? JSONDecoder().decode(Task.self, from: json.toJSONData()) {
                sample.tasks.append(TaskViewModel(task: task))
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
