//
//  NewsFormViewModel.swift
//  Life
//
//  Created by Shyngys Kassymov on 04.03.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import RxCocoa

class NewsFormViewModel: NSObject {

    let disposeBag = DisposeBag()

    let isLoadingSubject = BehaviorSubject<Bool>(value: false)
    let errorSubject = PublishSubject<Error>()
    let newsCreatedSubject = PublishSubject<News>()

    var coverImage: URL?
    var attachments = [URL]()

    let titleSubject = BehaviorSubject<String>(value: "")
    let textSubject = BehaviorSubject<String>(value: "")

    var userTags = Set<Tag>()
    var userAddedTags = Set<String>()
    var isLoadingTagsSubject: Observable<Bool> {
        return TagsProvider.isLoadingTagsSubject.asObservable()
    }
    var tags: [Tag] {
        return TagsProvider.tagsSubject.value
    }
    var tagsSubject: Observable<[Tag]> {
        return TagsProvider.tagsSubject.asObservable()
    }
    var filteredTags = [Tag]()

    var pickingMainImage = true

    let isHistoryEvent = BehaviorSubject<Bool>(value: false)
    let isPressService = BehaviorSubject<Bool>(value: true)

    private let newsProvider = MoyaProvider<NewsService>(
        plugins: [
            AuthPlugin(tokenClosure: {
                return User.current.token
            })
        ]
    )

    // MARK: - Methods

    public func createNews() {
        guard let title = try? titleSubject.value(),
            let text = try? textSubject.value(),
            let isHistoryEvent = try? isHistoryEvent.value(),
            let isPressService = try? isPressService.value() else {
                return
        }

        let tags = userTags.map { $0.getId() } + userAddedTags

        isLoadingSubject.onNext(true)
        newsProvider
            .rx
            .request(.createNews(
                mainImage: coverImage,
                secondaryImages: attachments,
                title: title,
                text: text,
                rawText: text,
                isHistoryEvent: isHistoryEvent,
                isPressService: isPressService,
                tags: tags)
            )
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                self.isLoadingSubject.onNext(false)
                switch response {
                case .success(let json):
                    if let news = try? JSONDecoder().decode(News.self, from: json.data) {
                        self.newsCreatedSubject.onNext(news)
                    }
                case .error(let error):
                    self.errorSubject.onNext(error)
                }
            }
            .disposed(by: disposeBag)
    }

    public func getTags() {
        TagsProvider.getTags()
    }
}
