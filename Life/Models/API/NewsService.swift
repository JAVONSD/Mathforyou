//
//  NewsService.swift
//  Life
//
//  Created by Shyngys Kassymov on 14.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import Moya

enum NewsService {
    case news(id: String)
    case likeNews(withId: String)
    case addCommentToNews(withId: String, commentText: String)
    case likeComment(newsId: String, commentId: String, voteType: UserVote)
}

extension NewsService: AuthorizedTargetType {

    var path: String {
        switch self {
        case .news(let id):
            return "/News/\(id)"
        case .likeNews(let id):
            return "/News/\(id)/like"
        case .addCommentToNews(let id, _):
            return "/News/\(id)/comments"
        case .likeComment(let newsId, let commentId, let voteType):
            return "/News/\(newsId)/comments/\(commentId)/like/\(voteType.rawValue)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .news:
            return .get
        case .addCommentToNews:
            return .post
        case .likeNews, .likeComment:
            return .put
        }
    }

    var task: Moya.Task {
        switch self {
        case .news, .likeNews, .likeComment:
            return .requestPlain
        case .addCommentToNews(_, let commentText):
            return .requestParameters(
                parameters: ["commentText": commentText],
                encoding: JSONEncoding.default
            )
        }
    }

    var sampleData: Data {
        switch self {
        case .news:
            return Bundle.main.stubJSONWith(name: "news_details")
        case .likeNews, .likeComment:
            return [:].toJSONData()
        case .addCommentToNews:
            return Bundle.main.stubJSONWith(name: "comment")
        }
    }

    var headers: [String: String]? {
        return nil
    }

    var needsAuth: Bool {
        return true
    }

}
