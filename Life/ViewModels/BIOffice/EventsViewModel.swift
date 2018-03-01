//
//  EventsViewModel.swift
//  Life
//
//  Created by Shyngys Kassymov on 19.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import DateToolsSwift
import IGListKit
import Moya
import RxSwift

class EventsViewModel: NSObject, ListDiffable {
    private(set) var events = [EventItemViewModel]()
    var minimized = true

    let disposeBag = DisposeBag()

    private let eventsSubject = PublishSubject<[EventItemViewModel]>()
    var eventsObservable: Observable<[EventItemViewModel]> { return eventsSubject.asObservable() }

    private let loadingSubject = PublishSubject<Bool>()
    var loading: Observable<Bool> { return loadingSubject.asObservable() }

    private let provider = MoyaProvider<EventsService>(
        plugins: [
            AuthPlugin(tokenClosure: {
                return User.current.token
            })
        ]
    )

    // MARK: - Methods

    public func getMine(completion: @escaping ((Error?) -> Void)) {
        loadingSubject.onNext(true)
        provider
            .rx
            .request(.mine(start: 1.months.earlier, end: 1.months.later))
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                self.loadingSubject.onNext(false)
                switch response {
                case .success(let json):
                    if let eventItems = try? JSONDecoder().decode([Event].self, from: json.data) {
                        let items = eventItems.map { EventItemViewModel(event: $0) }
                        self.events = items
                        completion(nil)
                    } else {
                        completion(nil)
                    }
                    self.eventsSubject.onNext(self.events)
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
