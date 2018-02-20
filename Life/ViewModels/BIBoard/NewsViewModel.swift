//
//  NewsViewModel.swift
//  Life
//
//  Created by Shyngys Kassymov on 19.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import IGListKit

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
            let json = [
                "title": "День открытых дверей пройдет в ЖК «Милано»"
            ]
            if let news = try? JSONDecoder().decode(News.self, from: json.toJSONData()) {
                sample.news.append(NewsItemViewModel(news: news))
            }
        }

        return sample
    }
}

class NewsItemViewModel: NSObject, ListDiffable {
    var news: News

    init(news: News) {
        self.news = news
    }

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
