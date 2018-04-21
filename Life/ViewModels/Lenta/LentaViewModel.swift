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
        return item.createDate.prettyDateOrTimeAgoString()
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

    enum FilterType: Int {
        case all = 0
        case news = 1
        case suggestions = 2
        case questionnaires = 3
    }

    var currentFilter = FilterType.all

    private var offset = 0
    private let rows = 10
    private(set) var canLoadMore = true
    let loading = BehaviorRelay<Bool>(value: false)
    private var usingCached = false
    private(set) var didLoad = false
    private(set) var didLoadFromCache = false

    private(set) var newsViewModel = NewsViewModel()
    private(set) var suggestionsViewModel = SuggestionsViewModel()
    private(set) var questionnairesViewModel = QuestionnairesViewModel()
    private(set) unowned var stuffViewModel: StuffViewModel

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

    init(stuffViewModel: StuffViewModel) {
        self.stuffViewModel = stuffViewModel
    }

    // MARK: - Methods

    func reload(_ completion: @escaping ((Error?) -> Void)) {
        fetchNextPage(reset: true, completion)
    }

    func fetchNextPage(
        reset: Bool = false,
        _ completion: @escaping ((Error?) -> Void)) {
        if loading.value || usingCached {
            completion(nil)
            return
        }

        loading.accept(true)

        if reset {
            offset = 0
        }
        if items.isEmpty && !self.usingCached {
            returnLentaFromCache(completion: completion)
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
                self.loading.accept(false)

                switch response {
                case .success(let json):
                    self.didLoad = true

                    if let lentaItems = try? JSONDecoder().decode([Lenta].self, from: json.data) {
                        let items = lentaItems.map { LentaItemViewModel(lenta: $0) }
                        if !reset && !self.usingCached {
                            self.items.append(contentsOf: items)
                        } else {
                            self.items = items
                            self.usingCached = false
                        }

                        self.canLoadMore = items.count >= self.rows
                        if self.canLoadMore {
                            self.offset += self.rows
                        }

                        completion(nil)

                        if self.items.count <= self.rows {
                            self.updateLentaCache(lentaItems)
                        }
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

    private func returnLentaFromCache(completion: @escaping ((Error?) -> Void)) {
        DispatchQueue.global().async {
            do {
                let realm = try App.Realms.default()
                let cachedLentaObjects = realm.objects(LentaObject.self)

                let cachedLentaItems = Array(cachedLentaObjects).map { Lenta(managedObject: $0) }
                let items = cachedLentaItems.map { LentaItemViewModel(lenta: $0) }

                self.usingCached = true
                self.items = items

                DispatchQueue.main.async {
                    if !items.isEmpty {
                        self.loading.accept(false)
                    }

                    self.didLoadFromCache = true

                    completion(nil)
                }
            } catch let error as NSError {
                print("Failed to access the Realm database with error - \(error.localizedDescription)")
            }
        }
    }

    private func updateLentaCache(_ lentaItems: [Lenta]) {
        DispatchQueue.global().async {
            do {
                let realm = try App.Realms.default()
                realm.beginWrite()
                realm.delete(realm.objects(LentaObject.self))
                for lentaItem in lentaItems {
                    realm.add(lentaItem.managedObject(), update: true)
                }
                try realm.commitWrite()
            } catch {
                print("Failed to access the Realm database")
            }
        }
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
        let lenta = LentaViewModel(stuffViewModel: StuffViewModel())

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
