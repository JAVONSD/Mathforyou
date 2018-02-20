//
//  EventsViewModel.swift
//  Life
//
//  Created by Shyngys Kassymov on 19.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import IGListKit

class EventsViewModel: NSObject, ListDiffable {
    var events = [EventItemViewModel]()
    var minimized = true

    func diffIdentifier() -> NSObjectProtocol {
        return self
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let object = object as? EventsViewModel {
            return self == object
        }
        return false
    }
}

extension EventsViewModel: Mockable {
    typealias T = EventsViewModel

    static func sample() -> EventsViewModel {
        let sample = EventsViewModel()

        for _ in 0..<3 {
            let json = [
                "title": "Встреча по ERP в малом зале на 9 этаже"
            ]
            if let event = try? JSONDecoder().decode(Event.self, from: json.toJSONData()) {
                sample.events.append(EventItemViewModel(event: event))
            }
        }

        return sample
    }
}

class EventItemViewModel: NSObject, ListDiffable {
    var event: Event

    init(event: Event) {
        self.event = event
    }

    func diffIdentifier() -> NSObjectProtocol {
        return NSString(string: event.id)
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let item = object as? EventItemViewModel {
            return event.id == item.event.id
        }
        return false
    }
}
