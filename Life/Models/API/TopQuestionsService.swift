//
//  TopQuestionsService.swift
//  Life
//
//  Created by Shyngys Kassymov on 14.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import Moya

enum TopQuestionsService {
    case topQuestions
    case answers
    case videoAnswers
    case createTopQuestion(
        questionText: String,
        isAnonymous: Bool,
        tags: [String]
    )
    case addAnswer(
        id: String,
        answerText: String
    )
    case addVideoAnswer(
        id: String,
        videoFile: URL
    )
    case delete(id: String)
}

extension TopQuestionsService: AuthorizedTargetType {

    var path: String {
        switch self {
        case .topQuestions, .createTopQuestion:
            return "/topQuestions"
        case .answers:
            return "/topQuestions/answers"
        case .videoAnswers:
            return "/topQuestions/videoAnswers"
        case .addAnswer(let id, _):
            return "/topQuestions/\(id)/answers"
        case .addVideoAnswer:
            return "/topQuestions/videoAnswers"
        case .delete(let id):
            return "/topQuestions/\(id)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .topQuestions, .answers, .videoAnswers:
            return .get
        case .createTopQuestion, .addAnswer, .addVideoAnswer:
            return .post
        case .delete:
            return .delete
        }
    }

    var task: Moya.Task {
        switch self {
        case .topQuestions, .answers, .videoAnswers, .delete:
            return .requestPlain
        case .createTopQuestion(
            let questionText,
            let isAnonymous,
            let tags):
            return .requestParameters(
                parameters: [
                    "questionText": questionText,
                    "isAnonymous": isAnonymous,
                    "tags": tags
                ],
                encoding: JSONEncoding.default
            )
        case .addAnswer(
            _,
            let answerText):
            return .requestParameters(
                parameters: [
                    "answerText": answerText
                ],
                encoding: JSONEncoding.default
            )
        case .addVideoAnswer(let id, let videoFile):
            var data = [MultipartFormData]()

            data.append(id.multipartFormData("QuestionIds"))
            data.append(videoFile.multipartFormData("VideoFile"))

            return .uploadMultipart(data)
        }
    }

    var sampleData: Data {
        switch self {
        case .topQuestions:
            return Bundle.main.stubJSONWith(name: "top_questions")
        case .createTopQuestion:
            return Bundle.main.stubJSONWith(name: "top_questions")
        case .answers:
            return Bundle.main.stubJSONWith(name: "top_question_answers")
        case .addAnswer:
            return Bundle.main.stubJSONWith(name: "top_question_answer")
        case .videoAnswers:
            return Bundle.main.stubJSONWith(name: "top_question_video_answers")
        case .addVideoAnswer:
            return Bundle.main.stubJSONWith(name: "top_question_video_answer")
        case .delete:
            return "{\"statusCode\": 200}".utf8Encoded
        }
    }

    var headers: [String: String]? {
        return nil
    }

    var needsAuth: Bool {
        return true
    }

}
