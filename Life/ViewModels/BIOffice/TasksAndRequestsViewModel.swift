//
//  TasksAndRequestsViewModel.swift
//  Life
//
//  Created by Shyngys Kassymov on 19.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import IGListKit

class TasksAndRequestsViewModel: NSObject, ListDiffable {
    var tasks = TasksViewModel()
    var requests = RequestsViewModel()
    var items: [ListDiffable] {
        var allItems = [ListDiffable]()
        allItems.append(contentsOf: tasks.tasks as [ListDiffable])
        allItems.append(contentsOf: requests.requests as [ListDiffable])
        return allItems
    }

    var minimized = true

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
