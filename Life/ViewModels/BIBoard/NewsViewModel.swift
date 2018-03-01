//
//  NewsViewModel.swift
//  Life
//
//  Created by Shyngys Kassymov on 19.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import IGListKit
import Moya
import RxSwift

class NewsViewModel: NSObject, ListDiffable {
    private(set) var news = [NewsItemViewModel]()
    private(set) var popularNews = [NewsItemViewModel]()
    private(set) var top3News = [NewsItemViewModel]()
    var minimized = true

    private let disposeBag = DisposeBag()

    private let popularNewsSubject = PublishSubject<[NewsItemViewModel]>()
    var popularNewsObservable: Observable<[NewsItemViewModel]> { return popularNewsSubject.asObservable() }

    private let top3NewsSubject = PublishSubject<[NewsItemViewModel]>()
    var top3NewsObservable: Observable<[NewsItemViewModel]> { return top3NewsSubject.asObservable() }

    private let loadingPopularSubject = PublishSubject<Bool>()
    var loadingPopular: Observable<Bool> { return loadingPopularSubject.asObservable() }

    private let loadingTop3Subject = PublishSubject<Bool>()
    var loadingTop3: Observable<Bool> { return loadingTop3Subject.asObservable() }

    private let provider = MoyaProvider<NewsService>(
        plugins: [
            AuthPlugin(tokenClosure: {
                return User.current.token
            })
        ]
    )

    // MARK: - Methods

    public func getPopularNews(completion: @escaping ((Error?) -> Void)) {
        loadingPopularSubject.onNext(true)
        provider
            .rx
            .request(.popularNews)
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                self.loadingPopularSubject.onNext(false)
                switch response {
                case .success(let json):
                    if let news = try? JSONDecoder().decode([News].self, from: json.data) {
                        self.popularNews = news.map { NewsItemViewModel(news: $0) }

                        completion(nil)
                    } else {
                        completion(nil)
                    }
                    self.popularNewsSubject.onNext(self.popularNews)
                case .error(let error):
                    completion(error)
                }
            }
            .disposed(by: disposeBag)
    }

    public func getTop3News(completion: @escaping ((Error?) -> Void)) {
        loadingTop3Subject.onNext(true)
        provider
            .rx
            .request(.topNews(top: 10))
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                self.loadingTop3Subject.onNext(false)
                switch response {
                case .success(let json):
                    if let news = try? JSONDecoder().decode([News].self, from: json.data) {
                        let news = news.map { NewsItemViewModel(news: $0) }
                        let newsWithImage = news.filter { viewModel in
                            var image = viewModel.news.imageStreamId ?? ""
                            if image.isEmpty {
                                image = viewModel.news.imageUrl
                            }
                            return !image.isEmpty
                        }

                        self.top3News = []
                        for i in 0..<min(3, newsWithImage.count) {
                            self.top3News.append(newsWithImage[i])
                        }

                        completion(nil)
                    } else {
                        completion(nil)
                    }
                    self.top3NewsSubject.onNext(self.top3News)
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
        if let object = object as? NewsViewModel {
            return self == object
        }
        return false
    }
}

extension NewsViewModel: Mockable {
    typealias T = NewsViewModel

    static func sample() -> NewsViewModel {
        let sample = NewsViewModel()

        for _ in 0..<3 {
            if let jsonPath = Bundle.main.path(forResource: "news_details", ofType: "json"),
                let news = try? JSONDecoder().decode(
                    News.self,
                    from: Data(contentsOf: URL(fileURLWithPath: jsonPath))) {
                sample.news.append(NewsItemViewModel(news: news))
            }
        }

        return sample
    }
}

class NewsItemViewModel: NSObject, ListDiffable {
    var news: News

    var needReloadOnWebViewLoad = true
    var calculatedWebViewHeight: CGFloat = 24

    private(set) var canLoadMore = true
    private(set) var loading = false

    private let disposeBag = DisposeBag()

    private let provider = MoyaProvider<NewsService>(
        plugins: [
            AuthPlugin(tokenClosure: {
                return User.current.token
            })
        ]
    )

    init(news: News) {
        self.news = news
    }

    init(id: String) {
        let json = ["id": id]
        //swiftlint:disable force_try
        self.news = try! JSONDecoder().decode(News.self, from: json.toJSONData())
        //swiftlint:enable force_try
    }

    // MARK: - Methods

    public func getNews(completion: @escaping ((Error?) -> Void)) {
        if loading {
            return
        }

        loading = true

        provider
            .rx
            .request(.news(id: news.id))
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                self.canLoadMore = false
                self.loading = false

                switch response {
                case .success(let json):
                    if let news = try? JSONDecoder().decode(News.self, from: json.data) {
                        self.news = news

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

    public func likeNews(completion: @escaping ((Error?) -> Void)) {
        if loading {
            return
        }

        loading = true

        provider
            .rx
            .request(.likeNews(withId: news.id))
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

    public func addCommentToNews(commentText: String, completion: @escaping ((Error?) -> Void)) {
        if loading {
            return
        }

        loading = true

        provider
            .rx
            .request(.addCommentToNews(withId: news.id, commentText: commentText))
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                self.canLoadMore = false
                self.loading = false

                switch response {
                case .success(let json):
                    if let comment = try? JSONDecoder().decode(Comment.self, from: json.data) {
                        self.news.comments.append(comment)

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
            .request(.likeComment(newsId: news.id, commentId: id, voteType: voteType))
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
        return NSString(string: news.id)
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let item = object as? NewsItemViewModel {
            return news.id == item.news.id
        }
        return false
    }
}
