//
//  GlobalSearchViewModel.swift
//  Life
//
//  Created by 123 on 27.07.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import IGListKit
import Moya
import RxSwift
import RxCocoa

class GlobalSearchViewModel: NSObject, ListDiffable {
    private(set) var news = [GlobalSearchItemViewModel]()
    private(set) var popularNews = [GlobalSearchItemViewModel]()
    private(set) var top3News = [GlobalSearchItemViewModel]()
    
    var minimized = true
    var didLoad = true
    
    private var offset = 0
    private let rows = 10
    private(set) var canLoadMore = true
    let loading = BehaviorRelay<Bool>(value: false)
    private var usingCached = false
    private(set) var didLoadFromRealmCache = false
    
    private let disposeBag = DisposeBag()
    
    private let newsSubject = PublishSubject<[GlobalSearchItemViewModel]>()
    var newsObservable: Observable<[GlobalSearchItemViewModel]> { return newsSubject.asObservable() }
    
    private let popularNewsSubject = PublishSubject<[GlobalSearchItemViewModel]>()
    var popularNewsObservable: Observable<[GlobalSearchItemViewModel]> { return popularNewsSubject.asObservable() }
    
    private let top3NewsSubject = PublishSubject<[GlobalSearchItemViewModel]>()
    var top3NewsObservable: Observable<[GlobalSearchItemViewModel]> { return top3NewsSubject.asObservable() }
    
    private let loadingAllSubject = PublishSubject<Bool>()
    var loadingAll: Observable<Bool> { return loadingAllSubject.asObservable() }
    
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
        
        returnNewsFromCache(completion: completion, type: .popular)
        
        provider
            .rx
            .request(.popularNews)
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                self.loadingPopularSubject.onNext(false)
                switch response {
                case .success(let json):
                    if let news = try? JSONDecoder().decode([News].self, from: json.data) {
                        self.popularNews = news.map { GlobalSearchItemViewModel(news: $0) }
                        
                        completion(nil)
                        
                        self.updateNewsCache(news, type: .popular)
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
        
        returnNewsFromCache(completion: completion, type: .top3)
        
        provider
            .rx
            .request(.topNews(top: 10))
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                self.loadingTop3Subject.onNext(false)
                switch response {
                case .success(let json):
                    if let news = try? JSONDecoder().decode([News].self, from: json.data) {
                        let news = news.map { GlobalSearchItemViewModel(news: $0) }
                        let newsWithImage = news.filter { viewModel in
                            var image = viewModel.news.imageStreamId ?? ""
                            if image.isEmpty {
                                image = viewModel.news.imageUrl
                            }
                            return !image.isEmpty
                        }
                        
                        self.top3News = []
                        for idx in 0..<min(3, newsWithImage.count) {
                            self.top3News.append(newsWithImage[idx])
                        }
                        
                        completion(nil)
                        
                        self.updateNewsCache(self.top3News.map { $0.news }, type: .top3)
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
        if news.isEmpty && !self.usingCached {
            returnNewsFromCache(completion: completion, type: .all)
        }
        
        provider
            .rx
            .request(
                .newsWithDetails(
                    rows: rows,
                    offset: offset
                ))
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                self.loading.accept(false)
                self.didLoad = true
                
                switch response {
                case .success(let json):
                    if let newsItems = try? JSONDecoder().decode([News].self, from: json.data) {
                        let items = newsItems.map { GlobalSearchItemViewModel(news: $0) }
                        if !reset && !self.usingCached {
                            self.news.append(contentsOf: items)
                        } else {
                            self.news = items
                            self.usingCached = false
                        }
                        
                        self.canLoadMore = items.count >= self.rows
                        if self.canLoadMore {
                            self.offset += self.rows
                        }
                        
                        completion(nil)
                        
                        if self.news.count <= self.rows {
                            self.updateNewsCache(newsItems, type: .all)
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
    
    private func returnNewsFromCache(completion: @escaping ((Error?) -> Void), type: ResultsType) {
        DispatchQueue.global().async {
            do {
                var realm = try App.Realms.default()
                if type == .popular {
                    realm = try App.Realms.popularNews()
                } else if type == .top3 {
                    realm = try App.Realms.topNews()
                }
                let cachedNewsObjects = realm.objects(NewsObject.self)
                
                let cachedNews = Array(cachedNewsObjects).map { News(managedObject: $0) }
                let items = cachedNews.map { GlobalSearchItemViewModel(news: $0) }
                
                if type == .all {
                    self.loadingAllSubject.onNext(false)
                    self.news = items
                    self.usingCached = true
                } else if type == .popular {
                    self.loadingPopularSubject.onNext(false)
                    self.popularNews = items
                } else if type == .top3 {
                    if !items.isEmpty {
                        self.loadingTop3Subject.onNext(false)
                    }
                    
                    self.top3News = items
                }
                
                DispatchQueue.main.async {
                    if type == .all {
                        if !items.isEmpty {
                            self.loading.accept(false)
                        }
                        
                        self.didLoadFromRealmCache = true
                        
                        self.newsSubject.onNext(items)
                    } else if type == .popular {
                        self.popularNewsSubject.onNext(items)
                    } else if type == .top3 {
                        self.top3NewsSubject.onNext(items)
                    }
                    
                    completion(nil)
                }
            } catch let error as NSError {
                print("Failed to access the Realm database with error - \(error.localizedDescription)")
            }
        }
    }
    
    private func updateNewsCache(_ newsItems: [News], type: ResultsType) {
        DispatchQueue.global().async {
            do {
                var realm = try App.Realms.default()
                if type == .popular {
                    realm = try App.Realms.popularNews()
                } else if type == .top3 {
                    realm = try App.Realms.topNews()
                }
                realm.beginWrite()
                realm.delete(realm.objects(NewsObject.self))
                for news in newsItems {
                    realm.add(news.managedObject(), update: true)
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
        if let object = object as? GlobalSearchViewModel {
            return self == object
        }
        return false
    }
}

extension GlobalSearchViewModel: Mockable {
    typealias T = GlobalSearchViewModel
    
    static func sample() -> GlobalSearchViewModel {
        let sample = GlobalSearchViewModel()
        
        for _ in 0..<3 {
            if let jsonPath = Bundle.main.path(forResource: "news_details", ofType: "json"),
                let news = try? JSONDecoder().decode(
                    News.self,
                    from: Data(contentsOf: URL(fileURLWithPath: jsonPath))) {
                sample.news.append(GlobalSearchItemViewModel(news: news))
            }
        }
        
        return sample
    }
}

class GlobalSearchItemViewModel: NSObject, ListDiffable {
    var news: News
    
    var needReloadOnWebViewLoad = true
    var calculatedWebViewHeight: CGFloat = 24
    
    private(set) var canLoadMore = true
    let loading = BehaviorRelay<Bool>(value: false)
    
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
        if loading.value {
            return
        }
        
        loading.accept(true)
        
        provider
            .rx
            .request(.news(id: news.id))
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                self.canLoadMore = false
                self.loading.accept(false)
                
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
        provider
            .rx
            .request(.addCommentToNews(withId: news.id, commentText: commentText))
            .filterSuccessfulStatusCodes()
            .subscribe { response in
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
    
    // MARK: - ListDiffable ( IGListKit )
    
    func diffIdentifier() -> NSObjectProtocol {
        return NSString(string: news.id)
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let item = object as? GlobalSearchItemViewModel {
            return news.id == item.news.id
        }
        return false
    }
}












