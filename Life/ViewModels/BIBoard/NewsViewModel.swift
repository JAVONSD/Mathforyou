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
    var news = [NewsItemViewModel]()
    var minimized = true

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
