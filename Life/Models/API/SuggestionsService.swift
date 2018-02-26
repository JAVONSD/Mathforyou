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
        }
    }

    var method: Moya.Method {
        switch self {
        case .suggestion:
            return .get
        case .addCommentToSuggestion:
            return .post
        case .likeSuggestion, .likeComment:
            return .put
        }
    }

    var task: Moya.Task {
        switch self {
        case .suggestion, .likeSuggestion, .likeComment:
            return .requestPlain
        case .addCommentToSuggestion(_, let commentText):
            return .requestParameters(
                parameters: ["commentText": commentText],
                encoding: JSONEncoding.default
            )
        }
    }

    var sampleData: Data {
        switch self {
        case .suggestion:
            return Bundle.main.stubJSONWith(name: "suggestion_details")
        case .likeSuggestion, .likeComment:
            return [:].toJSONData()
        case .addCommentToSuggestion:
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
