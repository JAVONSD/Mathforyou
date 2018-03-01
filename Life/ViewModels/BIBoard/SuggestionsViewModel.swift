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

class SuggestionsViewModel: NSObject, ListDiffable {
    private(set) var suggestions = [SuggestionItemViewModel]()
    private(set) var popularSuggestions = [SuggestionItemViewModel]()
    var minimized = true

    private let disposeBag = DisposeBag()

    let suggestionsSubject = PublishSubject<[SuggestionItemViewModel]>()
    let popularSuggestionsSubject = PublishSubject<[SuggestionItemViewModel]>()

    private let provider = MoyaProvider<SuggestionsService>(
        plugins: [
            AuthPlugin(tokenClosure: {
                return User.current.token
            })
        ]
    )

    // MARK: - Methods

    public func getSuggestions(completion: @escaping ((Error?) -> Void)) {
        provider
            .rx
            .request(.suggestions)
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                switch response {
                case .success(let json):
                    if let suggestions = try? JSONDecoder().decode([Suggestion].self, from: json.data) {
                        self.suggestions = suggestions.map { SuggestionItemViewModel(suggestion: $0) }

                        completion(nil)
                    } else {
                        completion(nil)
                    }
                    self.suggestionsSubject.onNext(self.suggestions)
                case .error(let error):
                    completion(error)
                }
            }
            .disposed(by: disposeBag)
    }

    public func getPopularSuggestions(completion: @escaping ((Error?) -> Void)) {
        provider
            .rx
            .request(.popularSuggestions)
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                switch response {
                case .success(let json):
                    if let suggestions = try? JSONDecoder().decode([Suggestion].self, from: json.data) {
                        self.popularSuggestions = suggestions.map { SuggestionItemViewModel(suggestion: $0) }

                        completion(nil)
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
