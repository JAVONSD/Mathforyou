//
//  QuestionnairesViewModel.swift
//  Life
//
//  Created by Shyngys Kassymov on 19.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import IGListKit

class QuestionnairesViewModel: NSObject, ListDiffable {
    var questionnaires = [QuestionnaireViewModel]()
    var minimized = true

    func diffIdentifier() -> NSObjectProtocol {
        return self
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let object = object as? QuestionnairesViewModel {
            return self == object
        }
        return false
    }
}

extension QuestionnairesViewModel: Mockable {
    typealias T = QuestionnairesViewModel

    static func sample() -> QuestionnairesViewModel {
        let sample = QuestionnairesViewModel()

        for _ in 0..<5 {
            let json = [
                "title": "Test questionnaire"
            ]
            if let questionnaire = try? JSONDecoder().decode(Questionnaire.self, from: json.toJSONData()) {
                let item = QuestionnaireViewModel(questionnaire: questionnaire)
                sample.questionnaires.append(item)
            }
        }

        return sample
    }
}

class QuestionnaireViewModel: NSObject, ListDiffable {
    var questionnaire: Questionnaire

    init(questionnaire: Questionnaire) {
        self.questionnaire = questionnaire
    }

    func diffIdentifier() -> NSObjectProtocol {
        return NSString(string: questionnaire.id)
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let item = object as? QuestionnaireViewModel {
            return questionnaire.id == item.questionnaire.id
        }
        return false
    }
}
