//
//  LentaViewModel.swift
//  Life
//
//  Created by Shyngys Kassymov on 14.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import IGListKit

struct ImageSize {
    var width: Int
    var height: Int
}

enum EntityType: Int {
    case news = 10, questionnaire = 20, suggestion = 30
}

class LentaItemViewModel: NSObject {
    var id: String
    var authorCode: String
    var authorAvatar: String
    var authorName: String
    var createDate: String
    var title: String
    var descr: String
    var image: String
    var imageStreamId: String?
    var imageSize: ImageSize
    var questionsQuantity: Int
    var commentsQuantity: Int
    var likesQuantity: Int
    var dislikesQuantity: Int
    var userVote: Int
    var isLikedByMe: Bool
    var viewsQuantity: Int
    var isFromSharepoint: Bool
    var entityType: EntityType

    init(json: [String: Any?]) {
        id = json["id"] as? String ?? UUID().uuidString
        authorCode = json["authorCode"] as? String ?? ""
        authorAvatar = json["authorAvatar"] as? String ?? ""
        authorName = json["authorName"] as? String ?? ""
        createDate = json["createDate"] as? String ?? ""
        title = json["title"] as? String ?? ""
        descr = json["description"] as? String ?? ""
        image = json["image"] as? String ?? ""
        imageStreamId = json["imageStreamId"] as? String ?? ""
        questionsQuantity = json["questionsQuantity"] as? Int ?? 0
        commentsQuantity = json["commentsQuantity"] as? Int ?? 0
        likesQuantity = json["likesQuantity"] as? Int ?? 0
        dislikesQuantity = json["dislikesQuantity"] as? Int ?? 0
        userVote = json["userVote"] as? Int ?? 0
        isLikedByMe = json["isLikedByMe"] as? Bool ?? false
        viewsQuantity = json["viewsQuantity"] as? Int ?? 0
        isFromSharepoint = json["isFromSharepoint"] as? Bool ?? false

        if let size = json["imageSize"] as? [String: Int] {
            let width = size["width"] ?? 0
            let height = size["height"] ?? 0
            imageSize = ImageSize(width: width, height: height)
        } else {
            imageSize = ImageSize(width: 0, height: 0)
        }

        if let entity = json["entityType"] as? [String: Any] {
            let type = entity["code"] as? Int ?? 0
            entityType = EntityType(rawValue: type) ?? .news
        } else {
            entityType = .news
        }
    }
}

extension LentaItemViewModel: ListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        return NSString(string: id)
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let item = object as? LentaItemViewModel {
            return id == item.id
        }
        return false
    }
}

class LentaViewModel: NSObject {
    private var offset = 0
    private var limit = 10

    var items = [LentaItemViewModel]()

    func reload(_ completion: (([LentaItemViewModel]) -> Void)) {
        offset = 0
        items = LentaViewModel.sample().items
        completion(items)
    }

    func fetchNextPage(_ completion: (([LentaItemViewModel]) -> Void)) {
        offset += 1
        items.append(contentsOf: LentaViewModel.sample().items)
        completion(items)
    }
}

extension LentaViewModel: ListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        return self
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let object = object as? LentaViewModel {
            return self == object
        }
        return false
    }
}

extension LentaViewModel: Mockable {
    typealias T = LentaViewModel

    static func sample() -> LentaViewModel {
        let lenta = LentaViewModel()

        let item1Json = [
            "authorName": "User",
            "createDate": "5 минут назад",
            "title": "Greyhound divisively hello coldly wonderfully marginally far upon excluding.",
            "likesQuantity": 453,
            "commentsQuantity": 3,
            "viewsQuantity": 23,
            "image": "asldfjksldf",
            "imageSize": [
                "width": 312,
                "height": 182
            ],
            "entityType": [
                "code": 10
            ]
            ] as [String : Any]
        let item1 = LentaItemViewModel(json: item1Json)
        lenta.items.append(item1)

        let item2Json = [
            "authorName": "Name",
            "createDate": "1 января 2018",
            "title": "Greyhound divisively hello?",
            "likesQuantity": 453,
            "commentsQuantity": 3,
            "viewsQuantity": 4350,
            "entityType": [
                "code": 20
            ]
            ] as [String : Any]
        let item2 = LentaItemViewModel(json: item2Json)
        lenta.items.append(item2)

        let item3Json = [
            "authorName": "Account",
            "createDate": "час назад",
            "title": "Greyhound divisively hello coldly wonderfully marginally far upon excluding.",
            "likesQuantity": 453,
            "commentsQuantity": 3,
            "viewsQuantity": 23,
            "isLikedByMe": true,
            "image": "asldfjksldf",
            "imageSize": [
                "width": 312,
                "height": 182
            ],
            "entityType": [
                "code": 10
            ]
            ] as [String : Any]
        let item3 = LentaItemViewModel(json: item3Json)
        lenta.items.append(item3)

        return lenta
    }
}
