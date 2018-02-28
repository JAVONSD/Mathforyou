//
//  SuggestionsService.swift
//  Life
//
//  Created by Shyngys Kassymov on 14.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import Moya

enum SuggestionsService {
    case suggestion(id: String)
    case likeSuggestion(withId: String, voteType: UserVote)
    case addCommentToSuggestion(withId: String, commentText: String)
    case likeComment(suggestionId: String, commentId: String, voteType: UserVote)
    case suggestions
    case createSuggestion(
        mainImage: URL,
        secondaryImages: [URL],
        title: String,
        text: String,
        tags: [String]
    )
    case updateSuggestion(
        id: String,
        mainImage: URL,
        secondaryImages: [URL],
        title: String,
        text: String,
        tags: [String]
    )
    case popularSuggestions
    case similarSuggestions(id: String)
    case suggestionsWithDetails(rows: Int, offset: Int)
}

extension SuggestionsService: AuthorizedTargetType {

    var path: String {
        switch self {
        case .suggestion(let id):
            return "/Suggestions/\(id)"
        case .likeSuggestion(let id, let voteType):
            return "/Suggestions/\(id)/like/\(voteType.rawValue)"
        case .addCommentToSuggestion(let id, _):
            return "/Suggestions/\(id)/comments"
        case .likeComment(let suggestionId, let commentId, let voteType):
            return "/Suggestions/\(suggestionId)/comments/\(commentId)/like/\(voteType.rawValue)"
        case .suggestions, .createSuggestion, .updateSuggestion:
            return "/Suggestions"
        case .popularSuggestions:
            return "/Suggestions/popular"
        case .similarSuggestions(let id):
            return "/Suggestions/\(id)/similar"
        case .suggestionsWithDetails:
            return "/Suggestions/withdetails"
        }
    }

    var method: Moya.Method {
        switch self {
        case .suggestion, .suggestions, .popularSuggestions,
             .similarSuggestions, .suggestionsWithDetails:
            return .get
        case .addCommentToSuggestion, .createSuggestion:
            return .post
        case .likeSuggestion, .likeComment, .updateSuggestion:
            return .put
        }
    }

    var task: Moya.Task {
        switch self {
        case .suggestion, .likeSuggestion, .likeComment,
             .suggestions, .popularSuggestions, .similarSuggestions:
            return .requestPlain
        case .addCommentToSuggestion(_, let commentText):
            return .requestParameters(
                parameters: ["commentText": commentText],
                encoding: JSONEncoding.default
            )
        case .createSuggestion(
            let mainImage,
            let secondaryImages,
            let title,
            let text,
            let tags):
            var data = [MultipartFormData]()

            let mainImage = mainImage.multipartFormData("MainImage")
            data.append(mainImage)

            for secondaryImage in secondaryImages {
                let secondaryImageData = secondaryImage.multipartFormData("SecondaryImages")
                data.append(secondaryImageData)
            }

            data.append(title.multipartFormData("Title"))
            data.append(text.multipartFormData("Text"))

            for tag in tags {
                data.append(tag.multipartFormData("Tags"))
            }

            return .uploadMultipart(data)
        case .updateSuggestion(
            let id,
            let mainImage,
            let secondaryImages,
            let title,
            let text,
            let tags):
            var data = [MultipartFormData]()

            data.append(id.multipartFormData("NewsId"))

            let mainImage = mainImage.multipartFormData("MainImage")
            data.append(mainImage)

            for secondaryImage in secondaryImages {
                let secondaryImageData = secondaryImage.multipartFormData("SecondaryImages")
                data.append(secondaryImageData)
            }

            data.append(title.multipartFormData("Title"))
            data.append(text.multipartFormData("Text"))

            for tag in tags {
                data.append(tag.multipartFormData("Tags"))
            }

            return .uploadMultipart(data)
        case .suggestionsWithDetails(let rows, let offset):
            return .requestParameters(
                parameters: ["rows": rows, "offset": offset],
                encoding: URLEncoding.default
            )
        }
    }

    var sampleData: Data {
        switch self {
        case .suggestion, .createSuggestion, .updateSuggestion:
            return Bundle.main.stubJSONWith(name: "suggestion_details")
        case .likeSuggestion, .likeComment:
            return [:].toJSONData()
        case .addCommentToSuggestion:
            return Bundle.main.stubJSONWith(name: "comment")
        case .suggestions, .popularSuggestions, .similarSuggestions, .suggestionsWithDetails:
            return Bundle.main.stubJSONWith(name: "suggestions")
        }
    }

    var headers: [String: String]? {
        return nil
    }

    var needsAuth: Bool {
        return true
    }

}
