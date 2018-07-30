//
//  SearchNewsViewModel.swift
//  Life
//
//  Created by 123 on 29.07.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import IGListKit
import Moya
import RealmSwift
import RxSwift
import RxCocoa

class SearchNewsViewModel: NSObject, ViewModel {
    
    private let disposeBag = DisposeBag()
    
    private(set) var loading = BehaviorRelay<Bool>(value: false)
    private(set) var didLoadNews = false
    
    let news = BehaviorRelay<[NewsSearch]>(value: [])
    var filterText = Observable.just("")
    
    let onSuccess = PublishSubject<Void>()
    let onError = PublishSubject<Error>()
 
    private var _provider: MoyaProvider<GlobalSearchService>?
    private var provider: MoyaProvider<GlobalSearchService> {
        if _provider != nil {
            return _provider!
        }
        let authPlugin = AuthPlugin(tokenClosure: {
            return User.current.token
        })
        _provider = MoyaProvider<GlobalSearchService>(plugins: [authPlugin])
        return _provider!
    }

    // MARK: - Methods
    
    public func searchNews(text: String) {
        loading.accept(true)
        
        provider
            .rx
            .request(.globalSearch(searchTxt: text, rows: 15, offset: 4, entityType: 60, isMobile: true))
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                self.loading.accept(false)
                
                print(self.provider.request(GlobalSearchService.globalSearch(searchTxt: "a", rows: 4, offset: 3, entityType: 60, isMobile: true), completion: { (res) in
                    print(res.value?.request?.url)
                    
                    let jsonData = (try? JSONSerialization.jsonObject(with: (res.value?.data)!, options: [])) as? [String: Any]
                    print(jsonData)
                    
                }))
                
                switch response {
                case .success(let json):
                    if let
                        jsonData = (try? JSONSerialization.jsonObject(with: json.data, options: [])) as? [String: Any],
                        let list = jsonData["result"] as? [[String: Any]] {
                        self.didLoadNews = true
                        
                        let newsItems = list.map {
                            try! JSONDecoder().decode(NewsSearch.self, from: $0.toJSONData() )
                        }
                        
                        DispatchQueue.main.async {
                           self.news.accept(newsItems)
                        }
                        
                        self.onSuccess.onNext(())
                        
                    } else {
                    }
                case .error(let error):
                    self.onError.onNext(error)
                }
            }
            .disposed(by: disposeBag)
    }
    
    public func filter(with text: String) {
        if text.isEmpty {
            return
        }
        
        DispatchQueue.global().async {
            let text = text.lowercased()
            self.searchNews(text: text)
            
            DispatchQueue.main.async {
                
            }
        }
    }

}



