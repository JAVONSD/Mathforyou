//
//  LentaViewModel.swift
//  Life
//
//  Created by Shyngys Kassymov on 14.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import DateToolsSwift
import IGListKit
import Moya
import RxSwift
import RxCocoa

class LentaItemViewModel: NSObject {
    var item: Lenta

    var timeAgo: String {
        return item.createDate.date.timeAgoSinceNow
    }

    init(lenta: Lenta) {
        item = lenta
    }
}

extension LentaItemViewModel: ListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        return NSString(string: item.id)
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let item = object as? LentaItemViewModel {
            return self.item.id == item.item.id
        }
        return false
    }
}

class LentaViewModel: NSObject {
    private var offset = 0
    private let rows = 10
    private(set) var canLoadMore = true
    private(set) var loading = false

    private var disposeBag = DisposeBag()

    private var _provider: MoyaProvider<LentaService>?
    private var provider: MoyaProvider<LentaService> {
        if _provider != nil {
            return _provider!
        }
        let authPlugin = AuthPlugin(tokenClosure: {
            return User.current.token
        })
        _provider = MoyaProvider<LentaService>(plugins: [authPlugin])
        return _provider!
    }

    var items = [LentaItemViewModel]()

    func reload(_ completion: @escaping ((Error?) -> Void)) {
        fetchNextPage(reset: true, completion)
    }

    func fetchNextPage(
        reset: Bool = false,
        _ completion: @escaping ((Error?) -> Void)) {
        if loading {
            completion(nil)
            return
        }

        loading = true

        if reset {
            offset = 0
            items = []
        }

        provider
            .rx
            .request(
                .lenta(
                    rows: rows,
                    offset: offset,
                    withDescription: true
                ))
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                self.loading = false

                switch response {
                case .success(let json):
                    if let lentaItems = try? JSONDecoder().decode([Lenta].self, from: json.data) {
                        let items = lentaItems.map { LentaItemViewModel(lenta: $0) }
                        self.items.append(contentsOf: items)

                        self.canLoadMore = items.count >= self.rows
                        if self.canLoadMore {
                            self.offset += 1
                        }

                        completion(nil)
                    } else {
                        self.canLoadMore = false
                        completion(nil)
                    }
                case .error(let error):
                    self.canLoadMore = false
                    completion(error)
                }
            }
            .disposed(by: disposeBag)
    }

    public func add(item: Lenta) {
        items.insert(LentaItemViewModel(lenta: item), at: 0)
    }
}

extension LentaViewModel: ListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        return self
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let object = object as? LentaViewModel {
            return self == object
        }
        return false
    }
}

//swiftlint:disable function_body_length

extension LentaViewModel: Mockable {
    typealias T = LentaViewModel

    static func sample() -> LentaViewModel {
        let lenta = LentaViewModel()

        let item1Json = [
            "authorName": "User",
            "createDate": "5 минут назад",
            "title": "Greyhound divisively hello coldly wonderfully marginally far upon excluding.",
            "likesQuantity": 453,
            "commentsQuantity": 3,
            "viewsQuantity": 23,
            "image": "asldfjksldf",
            "imageSize": [
                "width": 312,
                "height": 182
            ],
            "entityType": [
                "code": 10
            ]
            ] as [String : Any]
        if let litem1 = try? JSONDecoder().decode(Lenta.self, from: item1Json.toJSONData()) {
            let item1 = LentaItemViewModel(lenta: litem1)
            lenta.items.append(item1)
        }

        let item2Json = [
            "authorName": "Name",
            "createDate": "1 января 2018",
            "title": "Greyhound divisively hello?",
            "likesQuantity": 453,
            "commentsQuantity": 3,
            "viewsQuantity": 4350,
            "entityType": [
                "code": 20
            ]
            ] as [String : Any]
        if let litem2 = try? JSONDecoder().decode(Lenta.self, from: item2Json.toJSONData()) {
            let item2 = LentaItemViewModel(lenta: litem2)
            lenta.items.append(item2)
        }

        let item3Json = [
            "authorName": "Account",
            "createDate": "час назад",
            "title": "Greyhound divisively hello coldly wonderfully marginally far upon excluding.",
            "likesQuantity": 453,
            "commentsQuantity": 3,
            "viewsQuantity": 23,
            "isLikedByMe": true,
            "image": "asldfjksldf",
            "imageSize": [
                "width": 312,
                "height": 182
            ],
            "entityType": [
                "code": 10
            ]
            ] as [String : Any]
        if let litem3 = try? JSONDecoder().decode(Lenta.self, from: item3Json.toJSONData()) {
            let item3 = LentaItemViewModel(lenta: litem3)
            lenta.items.append(item3)
        }

        return lenta
    }
}

//swiftlint:enable function_body_length
