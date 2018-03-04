//
//  SuggestionFormViewModel.swift
//  Life
//
//  Created by Shyngys Kassymov on 04.03.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import RxCocoa

class SuggestionFormViewModel: NSObject {

    let disposeBag = DisposeBag()

    let isLoadingSubject = BehaviorSubject<Bool>(value: false)
    let errorSubject = PublishSubject<Error>()
    let suggestionCreatedSubject = PublishSubject<Suggestion>()

    var coverImage: URL?
    var attachments = [URL]()

    let titleSubject = BehaviorSubject<String>(value: "")
    let textSubject = BehaviorSubject<String>(value: "")

    var userTags = Set<Tag>()
    var userAddedTags = Set<String>()
    let isLoadingTagsSubject = BehaviorSubject<Bool>(value: false)
    let tagsSubject = BehaviorSubject<[Tag]>(value: [])
    let filteredTagsSubject = BehaviorSubject<[Tag]>(value: [])

    private let suggestionsProvider = MoyaProvider<SuggestionsService>(
        plugins: [
            AuthPlugin(tokenClosure: {
                return User.current.token
            })
        ]
    )

    private let referencesProvider = MoyaProvider<ReferencesService>(
        plugins: [
            AuthPlugin(tokenClosure: {
                return User.current.token
            })
        ]
    )

    // MARK: - Methods

    public func createSuggestion() {
        guard let title = try? titleSubject.value(),
            let text = try? textSubject.value() else {
                return
        }

        let tags = userTags.map { $0.getId() } + userAddedTags

        isLoadingSubject.onNext(true)
        suggestionsProvider
            .rx
            .request(.createSuggestion(
                mainImage: coverImage,
                secondaryImages: attachments,
                title: title,
                text: text,
                tags: tags)
            )
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                self.isLoadingSubject.onNext(false)
                switch response {
                case .success(let json):
                    if let suggestion = try? JSONDecoder().decode(Suggestion.self, from: json.data) {
                        self.suggestionCreatedSubject.onNext(suggestion)
                    }
                case .error(let error):
                    self.errorSubject.onNext(error)
                }
            }
            .disposed(by: disposeBag)
    }

    public func getTags() {
        isLoadingTagsSubject.onNext(true)
        referencesProvider
            .rx
            .request(.tags)
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                self.isLoadingTagsSubject.onNext(false)
                switch response {
                case .success(let json):
                    if let tags = try? JSONDecoder().decode([Tag].self, from: json.data) {
                        self.tagsSubject.onNext(tags)
                    }
                case .error:
                    print("Error to load tags")
                }
            }
            .disposed(by: disposeBag)
    }
}
