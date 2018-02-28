//
//  QuestionnairesService.swift
//  Life
//
//  Created by Shyngys Kassymov on 14.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import Moya

enum QuestionnairesService {
    case questionnaires
    case questionnaire(id: String)
    case questionnaireDescription(id: String)
    case addAnswer(
        id: String,
        questionId: String,
        variantId: String,
        isCommented: Bool,
        commenteText: String
    )
    case questionnaireStatistics(id: String)
    case createQuestionnaire(
        mainImage: URL,
        secondaryImages: [URL],
        name: String,
        description: String,
        isAllCompany: String,
        isAnonymous: Bool,
        respondents: [String],
        questions: [String]
    )
    case popularQuestionnaires
    case questionnairesWithDetails(rows: Int, offset: Int)
}

extension QuestionnairesService: AuthorizedTargetType {

    var path: String {
        switch self {
        case .questionnaires, .createQuestionnaire:
            return "/Questionnaires"
        case .questionnaire(let id):
            return "/Questionnaires/\(id)"
        case .questionnaireDescription(let id):
            return "/Questionnaires/\(id)/description"
        case .addAnswer(let id, let questionId, _, _, _):
            return "/Questionnaires/\(id)/questions/\(questionId)/userAnswers"
        case .questionnaireStatistics(let id):
            return "/Questionnaires/\(id)/statistics"
        case .popularQuestionnaires:
            return "/Questionnaires/popular"
        case .questionnairesWithDetails:
            return "/Questionnaires/withdetails"
        }
    }

    var method: Moya.Method {
        switch self {
        case .questionnaire, .questionnaires, .popularQuestionnaires,
             .questionnairesWithDetails, .questionnaireDescription, .questionnaireStatistics:
            return .get
        case .addAnswer, .createQuestionnaire:
            return .post
        }
    }

    var task: Moya.Task {
        switch self {
        case .questionnaires, .questionnaire, .questionnaireDescription,
             .questionnaireStatistics, .popularQuestionnaires:
            return .requestPlain
        case .addAnswer(
            _,
            _,
            let variantId,
            let isCommented,
            let commenteText):
            return .requestParameters(
                parameters: [
                    "userAnswerVariantIds": [variantId],
                    "isCommented": isCommented,
                    "userAnswerCommentText": commenteText
                ],
                encoding: JSONEncoding.default
            )
        case .createQuestionnaire(
            let mainImage,
            let secondaryImages,
            let name,
            let description,
            let isAllCompany,
            let isAnonymous,
            let respondents,
            let questions):
            var data = [MultipartFormData]()

            let mainImage = mainImage.multipartFormData("MainImage")
            data.append(mainImage)

            for secondaryImage in secondaryImages {
                let secondaryImageData = secondaryImage.multipartFormData("SecondaryImages")
                data.append(secondaryImageData)
            }

            data.append(name.multipartFormData("Name"))
            data.append(description.multipartFormData("Description"))
            data.append(String(isAllCompany).multipartFormData("IsAllCompany"))
            data.append(String(isAnonymous).multipartFormData("IsAnonymous"))

            for respondent in respondents {
                data.append(respondent.multipartFormData("Respondents"))
            }
            for question in questions {
                data.append(question.multipartFormData("Questions"))
            }

            return .uploadMultipart(data)
        case .questionnairesWithDetails(let rows, let offset):
            return .requestParameters(
                parameters: ["rows": rows, "offset": offset],
                encoding: URLEncoding.default
            )
        }
    }

    var sampleData: Data {
        switch self {
        case .questionnaire, .createQuestionnaire, .questionnaireDescription:
            return Bundle.main.stubJSONWith(name: "questionnaire")
        case .questionnaires, .popularQuestionnaires, .questionnairesWithDetails:
            return Bundle.main.stubJSONWith(name: "questionnaires")
        case .questionnaireStatistics:
            return Bundle.main.stubJSONWith(name: "questionnaire_statistics")
        case .addAnswer:
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
