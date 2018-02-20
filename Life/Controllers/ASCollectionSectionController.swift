//
//  ASCollectionSectionController.swift
//  Life
//
//  Created by Shyngys Kassymov on 16.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import IGListKit

class ASCollectionSectionController: ListSectionController {

    private(set) var items = [ListDiffable]()

    private let diffingQueue = DispatchQueue(label: "ASCollectionSectionController.diffingQueue")
    private var pendingItems = [ListDiffable]()
    private var initialItemsRead = false

    // MARK: - Methods

    override func numberOfItems() -> Int {
        if initialItemsRead == false {
            pendingItems = items
            initialItemsRead = true
        }
        return items.count
    }

    public func set(items: [ListDiffable], animated: Bool, completion: (() -> Void)?) {
        assert(Thread.isMainThread, "This method must be called from the main thread")

        let newItems = items
        if !initialItemsRead {
            self.items = newItems
            if let completion = completion {
                completion()
            }
            return
        }

        diffingQueue.async {
            let result = ListDiff(
                oldArray: self.pendingItems,
                newArray: newItems,
                option: .pointerPersonality)
            self.pendingItems = newItems

            DispatchQueue.main.async {
                let ctx = self.collectionContext
                ctx?.performBatch(animated: animated, updates: { (batchContext) in
                    batchContext.reload(in: self, at: result.updates)
                    batchContext.insert(in: self, at: result.inserts)
                    batchContext.delete(in: self, at: result.deletes)
                    self.items = newItems
                }, completion: { _ in
                    if let completion = completion {
                        completion()
                    }
                })
            }
        }
    }

}
