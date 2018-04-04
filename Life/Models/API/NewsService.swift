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
    case topNews(top: Int)
    case news(id: String)
    case likeNews(withId: String)
    case addCommentToNews(withId: String, commentText: String)
    case likeComment(newsId: String, commentId: String, voteType: UserVote)
    case createNews(
        mainImage: URL?,
        secondaryImages: [URL],
        title: String,
        text: String,
        rawText: String,
        isHistoryEvent: Bool,
        isPressService: Bool,
        tags: [String]
    )
    case updateNews(
        id: String,
        mainImage: URL?,
        secondaryImages: [URL],
        title: String,
        text: String,
        rawText: String,
        isHistoryEvent: Bool,
        isPressService: Bool,
        tags: [String]
    )
    case popularNews
    case newsWithDetails(rows: Int, offset: Int)
}

extension NewsService: AuthorizedTargetType {

    var path: String {
        switch self {
        case .topNews, .createNews, .updateNews:
            return "/News"
        case .news(let id):
            return "/News/\(id)"
        case .likeNews(let id):
            return "/News/\(id)/like"
        case .addCommentToNews(let id, _):
            return "/News/\(id)/comments"
        case .likeComment(let newsId, let commentId, let voteType):
            return "/News/\(newsId)/comments/\(commentId)/like/\(voteType.rawValue)"
        case .popularNews:
            return "/News/popular"
        case .newsWithDetails:
            return "/News/withdetails"
        }
    }

    var method: Moya.Method {
        switch self {
        case .news, .topNews, .popularNews, .newsWithDetails:
            return .get
        case .addCommentToNews, .createNews:
            return .post
        case .likeNews, .likeComment, .updateNews:
            return .put
        }
    }

    var task: Moya.Task {
        switch self {
        case .news, .likeNews, .likeComment, .popularNews:
            return .requestPlain
        case .addCommentToNews(_, let commentText):
            return .requestParameters(
                parameters: ["commentText": commentText],
                encoding: JSONEncoding.default
            )
        case .topNews(let top):
            return .requestParameters(
                parameters: ["top": top],
                encoding: URLEncoding.default
            )
        case .createNews(
            let mainImage,
            let secondaryImages,
            let title,
            let text,
            let rawText,
            let isHistoryEvent,
            let isPressService,
            let tags):
            var data = [MultipartFormData]()

            if let mainImage = mainImage {
                let mainImageData = mainImage.multipartFormData("MainImage")
                data.append(mainImageData)
            }

            for secondaryImage in secondaryImages {
                let secondaryImageData = secondaryImage.multipartFormData("SecondaryImages")
                data.append(secondaryImageData)
            }

            data.append(title.multipartFormData("Title"))
            data.append(text.multipartFormData("Text"))
            data.append(rawText.multipartFormData("RawText"))
            data.append(String(isHistoryEvent).multipartFormData("IsHistoryEvent"))
            data.append(String(isPressService).multipartFormData("IsPressService"))

            for tag in tags {
                data.append(tag.multipartFormData("Tags"))
            }

            return .uploadMultipart(data)
        case .updateNews(
            let id,
            let mainImage,
            let secondaryImages,
            let title,
            let text,
            let rawText,
            let isHistoryEvent,
            let isPressService,
            let tags):
            var data = [MultipartFormData]()

            data.append(id.multipartFormData("NewsId"))

            if let mainImage = mainImage {
                let mainImage = mainImage.multipartFormData("MainImage")
                data.append(mainImage)
            }

            for secondaryImage in secondaryImages {
                let secondaryImageData = secondaryImage.multipartFormData("SecondaryImages")
                data.append(secondaryImageData)
            }

            data.append(title.multipartFormData("Title"))
            data.append(text.multipartFormData("Text"))
            data.append(rawText.multipartFormData("RawText"))
            data.append(String(isHistoryEvent).multipartFormData("IsHistoryEvent"))
            data.append(String(isPressService).multipartFormData("IsPressService"))

            for tag in tags {
                data.append(tag.multipartFormData("Tags"))
            }

            return .uploadMultipart(data)
        case .newsWithDetails(let rows, let offset):
            return .requestParameters(
                parameters: ["rows": rows, "offset": offset],
                encoding: URLEncoding.default
            )
        }
    }

    var sampleData: Data {
        switch self {
        case .news, .createNews, .updateNews:
            return Bundle.main.stubJSONWith(name: "news_details")
        case .topNews, .popularNews, .newsWithDetails:
            return Bundle.main.stubJSONWith(name: "news")
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
