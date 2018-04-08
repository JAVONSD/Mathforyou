//
//  SuggestionsViewModel.swift
//  Life
//
//  Created by Shyngys Kassymov on 19.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import IGListKit
import Moya
import RxSwift
import RxCocoa

class SuggestionsViewModel: NSObject, ListDiffable {
    private(set) var suggestions = [SuggestionItemViewModel]()
    private(set) var allSuggestions = [SuggestionItemViewModel]()
    private(set) var popularSuggestions = [SuggestionItemViewModel]()

    var minimized = true
    var didLoad = false

    private var offset = 0
    private let rows = 10
    private(set) var canLoadMore = true
    let loading = BehaviorRelay<Bool>(value: false)
    private var usingCached = false
    private(set) var didLoadFromCache = false

    private let disposeBag = DisposeBag()

    private let loadingSuggestionsSubject = PublishSubject<Bool>()
    var loadingSuggestions: Observable<Bool> {
        return loadingSuggestionsSubject.asObservable()
    }
    private let suggestionsSubject = PublishSubject<[SuggestionItemViewModel]>()
    var suggestionsObservable: Observable<[SuggestionItemViewModel]> {
        return suggestionsSubject.asObservable()
    }

    private let loadingAllSuggestionsSubject = PublishSubject<Bool>()
    var loadingAllSuggestions: Observable<Bool> {
        return loadingAllSuggestionsSubject.asObservable()
    }
    private let allSuggestionsSubject = PublishSubject<[SuggestionItemViewModel]>()
    var allSuggsetionsObservable: Observable<[SuggestionItemViewModel]> {
        return allSuggestionsSubject.asObservable()
    }

    private let loadingPopularSuggestionsSubject = PublishSubject<Bool>()
    var loadingPopularSuggestions: Observable<Bool> {
        return loadingPopularSuggestionsSubject.asObservable()
    }
    private let popularSuggestionsSubject = PublishSubject<[SuggestionItemViewModel]>()
    var popularSuggestionsObservable: Observable<[SuggestionItemViewModel]> {
        return popularSuggestionsSubject.asObservable()
    }

    var loadingAllAndPopularSuggestions: Observable<Bool> {
        return Observable
            .zip(loadingSuggestions, loadingPopularSuggestions)
            .map { (load1, load2) in return load1 && load2 }
    }

    private let provider = MoyaProvider<SuggestionsService>(
        plugins: [
            AuthPlugin(tokenClosure: {
                return User.current.token
            })
        ]
    )

    // MARK: - Methods

    public func getSuggestions(completion: @escaping ((Error?) -> Void)) {
        loadingAllSuggestionsSubject.onNext(true)

        returnSuggestionsFromCache(completion: completion, type: .top3)

        provider
            .rx
            .request(.suggestions)
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                self.loadingAllSuggestionsSubject.onNext(false)
                self.didLoad = true

                switch response {
                case .success(let json):
                    if let suggestions = try? JSONDecoder().decode([Suggestion].self, from: json.data) {
                        self.allSuggestions = suggestions.map { SuggestionItemViewModel(suggestion: $0) }

                        completion(nil)

                        self.updateSuggestionsCache(suggestions, type: .top3)
                    } else {
                        completion(nil)
                    }
                    self.allSuggestionsSubject.onNext(self.allSuggestions)
                case .error(let error):
                    completion(error)
                }
            }
            .disposed(by: disposeBag)
    }

    public func getPopularSuggestions(completion: @escaping ((Error?) -> Void)) {
        loadingPopularSuggestionsSubject.onNext(true)

        returnSuggestionsFromCache(completion: completion, type: .popular)

        provider
            .rx
            .request(.popularSuggestions)
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                self.loadingPopularSuggestionsSubject.onNext(false)
                switch response {
                case .success(let json):
                    if let suggestions = try? JSONDecoder().decode([Suggestion].self, from: json.data) {
                        self.popularSuggestions = suggestions.map { SuggestionItemViewModel(suggestion: $0) }

                        completion(nil)

                        self.updateSuggestionsCache(suggestions, type: .popular)
                    } else {
                        completion(nil)
                    }
                    self.popularSuggestionsSubject.onNext(self.popularSuggestions)
                case .error(let error):
                    completion(error)
                }
            }
            .disposed(by: disposeBag)
    }

    func reload(_ completion: @escaping ((Error?) -> Void)) {
        fetchNextPage(reset: true, completion)
    }

    func fetchNextPage(
        reset: Bool = false,
        _ completion: @escaping ((Error?) -> Void)) {
        if loading.value {
            completion(nil)
            return
        }

        loading.accept(true)

        if reset {
            offset = 0
        }
        if suggestions.isEmpty && !self.usingCached {
            returnSuggestionsFromCache(completion: completion, type: .all)
        }

        provider
            .rx
            .request(
                .suggestionsWithDetails(
                    rows: rows,
                    offset: offset
                ))
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                self.loading.accept(false)
                self.didLoad = true

                switch response {
                case .success(let json):
                    if let suggestionsItems = try? JSONDecoder().decode([Suggestion].self, from: json.data) {
                        let items = suggestionsItems.map { SuggestionItemViewModel(suggestion: $0) }
                        if !reset && !self.usingCached {
                            self.suggestions.append(contentsOf: items)
                        } else {
                            self.suggestions = items
                            self.usingCached = false
                        }

                        self.canLoadMore = items.count >= self.rows
                        if self.canLoadMore {
                            self.offset += self.rows
                        }

                        completion(nil)

                        if self.suggestions.count <= self.rows {
                            self.updateSuggestionsCache(suggestionsItems, type: .all)
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

    public func add(suggestion: Suggestion) {
        suggestions.insert(SuggestionItemViewModel(suggestion: suggestion), at: 0)
    }

    private func returnSuggestionsFromCache(completion: @escaping ((Error?) -> Void), type: ResultsType) {
        DispatchQueue.global().async {
            do {
                var realm = try App.Realms.default()
                if type == .top3 {
                    realm = try App.Realms.allSuggestions()
                } else if type == .popular {
                    realm = try App.Realms.popularSuggestions()
                }
                let cachedSuggestionObjects = realm.objects(SuggestionObject.self)

                let cachedSuggestions = Array(cachedSuggestionObjects).map { Suggestion(managedObject: $0) }
                let items = cachedSuggestions.map { SuggestionItemViewModel(suggestion: $0) }

                if type == .popular {
                    self.loadingPopularSuggestionsSubject.onNext(false)
                    self.popularSuggestions = items
                } else if type == .all {
                    self.loadingSuggestionsSubject.onNext(false)
                    self.suggestions = items
                    self.usingCached = true
                } else {
                    self.loadingAllSuggestionsSubject.onNext(false)
                    self.allSuggestions = items
                }

                DispatchQueue.main.async {
                    if type == .popular {
                        self.popularSuggestionsSubject.onNext(items)
                    } else if type == .all {
                        if !items.isEmpty {
                            self.loading.accept(false)
                        }

                        self.suggestionsSubject.onNext(items)
                    } else {
                        self.allSuggestionsSubject.onNext(items)
                    }

                    self.didLoadFromCache = true

                    completion(nil)
                }
            } catch let error as NSError {
                print("Failed to access the Realm database with error - \(error.localizedDescription)")
            }
        }
    }

    private func updateSuggestionsCache(_ suggestionItems: [Suggestion], type: ResultsType) {
        DispatchQueue.global().async {
            do {
                var realm = try App.Realms.default()
                if type == .top3 {
                    realm = try App.Realms.allSuggestions()
                } else if type == .popular {
                    realm = try App.Realms.popularSuggestions()
                }
                realm.beginWrite()
                realm.delete(realm.objects(SuggestionObject.self))
                for suggestion in suggestionItems {
                    realm.add(suggestion.managedObject(), update: true)
                }
                try realm.commitWrite()
            } catch {
                print("Failed to access the Realm database")
            }
        }
    }

    // MARK: - ListDiffable

    func diffIdentifier() -> NSObjectProtocol {
        return self
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let object = object as? SuggestionsViewModel {
            return self == object
        }
        return false
    }
}

extension SuggestionsViewModel: Mockable {
    typealias T = SuggestionsViewModel

    static func sample() -> SuggestionsViewModel {
        let sample = SuggestionsViewModel()

        for _ in 0..<3 {
            if let jsonPath = Bundle.main.path(forResource: "suggestion_details", ofType: "json"),
                let suggestion = try? JSONDecoder().decode(
                    Suggestion.self,
                    from: Data(contentsOf: URL(fileURLWithPath: jsonPath))) {
                sample.suggestions.append(SuggestionItemViewModel(suggestion: suggestion))
            }
        }

        return sample
    }
}

class SuggestionItemViewModel: NSObject, ListDiffable {
    var suggestion: Suggestion

    var needReloadOnWebViewLoad = true
    var calculatedWebViewHeight: CGFloat = 24

    private(set) var canLoadMore = true
    private(set) var loading = false

    private let disposeBag = DisposeBag()

    private let provider = MoyaProvider<SuggestionsService>(
        plugins: [
            AuthPlugin(tokenClosure: {
                return User.current.token
            })
        ]
    )

    init(suggestion: Suggestion) {
        self.suggestion = suggestion
    }

    init(id: String) {
        let json = ["id": id]
        //swiftlint:disable force_try
        self.suggestion = try! JSONDecoder().decode(Suggestion.self, from: json.toJSONData())
        //swiftlint:enable force_try
    }

    // MARK: - Methods

    public func getSuggestion(completion: @escaping ((Error?) -> Void)) {
        if loading {
            return
        }

        loading = true

        provider
            .rx
            .request(.suggestion(id: suggestion.id))
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                self.canLoadMore = false
                self.loading = false

                switch response {
                case .success(let json):
                    if let suggestion = try? JSONDecoder().decode(Suggestion.self, from: json.data) {
                        self.suggestion = suggestion

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

    public func likeSuggestion(vote: UserVote, completion: @escaping ((Error?) -> Void)) {
        if loading {
            return
        }

        loading = true

        provider
            .rx
            .request(.likeSuggestion(withId: suggestion.id, voteType: vote))
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                switch response {
                case .success:
                    completion(nil)
                case .error(let error):
                    completion(error)
                }
            }
            .disposed(by: disposeBag)
    }

    public func addCommentToSuggestion(commentText: String, completion: @escaping ((Error?) -> Void)) {
        if loading {
            return
        }

        loading = true

        provider
            .rx
            .request(.addCommentToSuggestion(withId: suggestion.id, commentText: commentText))
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                self.canLoadMore = false
                self.loading = false

                switch response {
                case .success(let json):
                    if let comment = try? JSONDecoder().decode(Comment.self, from: json.data) {
                        self.suggestion.comments.append(comment)

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

    public func likeComment(id: String, voteType: UserVote, completion: @escaping ((Error?) -> Void)) {
        if loading {
            return
        }

        loading = true

        provider
            .rx
            .request(.likeComment(suggestionId: suggestion.id, commentId: id, voteType: voteType))
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                switch response {
                case .success:
                    completion(nil)
                case .error(let error):
                    completion(error)
                }
            }
            .disposed(by: disposeBag)
    }

    // MARK: - ListDiffable

    func diffIdentifier() -> NSObjectProtocol {
        return NSString(string: suggestion.id)
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let item = object as? SuggestionItemViewModel {
            return suggestion.id == item.suggestion.id
        }
        return false
    }
}
