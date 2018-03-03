//
//  QuestionFormViewModel.swift
//  Life
//
//  Created by Shyngys Kassymov on 03.03.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import IGListKit
import Moya
import RxSwift
import RxCocoa

class QuestionFormViewModel: NSObject, ViewModel {
    private let disposeBag = DisposeBag()

    let isLoadingSubject = BehaviorSubject<Bool>(value: false)
    let errorSubject = PublishSubject<Error>()
    let questionCreatedSubject = PublishSubject<Question>()

    let questionText = BehaviorSubject<String>(value: "")
    var userTags = Set<Tag>()
    var userAddedTags = Set<String>()
    let isAnanymous = BehaviorSubject<Bool>(value: false)

    let isLoadingTagsSubject = BehaviorSubject<Bool>(value: false)
    let tagsSubject = BehaviorSubject<[Tag]>(value: [])
    let filteredTagsSubject = BehaviorSubject<[Tag]>(value: [])

    private let topQuestionsProvider = MoyaProvider<TopQuestionsService>(
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

    public func createQuestion() {
        guard let questionText = try? questionText.value(),
            let isAnonymous = try? isAnanymous.value() else {
            return
        }

        let tags = userTags.map { $0.getId() } + userAddedTags

        isLoadingSubject.onNext(true)
        topQuestionsProvider
            .rx
            .request(.createTopQuestion(
                questionText: questionText,
                isAnonymous: isAnonymous,
                tags: tags))
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                self.isLoadingSubject.onNext(false)
                switch response {
                case .success(let json):
                    if let question = try? JSONDecoder().decode(Question.self, from: json.data) {
                        self.questionCreatedSubject.onNext(question)
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
