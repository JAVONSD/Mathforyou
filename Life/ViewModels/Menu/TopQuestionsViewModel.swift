//
//  TopQuestionsViewModel.swift
//  Life
//
//  Created by Shyngys Kassymov on 19.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import IGListKit

class TopQuestionsViewModel: NSObject, ViewModel, ListDiffable {
    var questions = [TopQuestionItemViewModel]()
    var minimized = true

    func diffIdentifier() -> NSObjectProtocol {
        return self
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let object = object as? TopQuestionsViewModel {
            return self == object
        }
        return false
    }
}

extension TopQuestionsViewModel: Mockable {
    typealias T = TopQuestionsViewModel

    static func sample() -> TopQuestionsViewModel {
        let menuViewModel = TopQuestionsViewModel()

        for _ in 0..<10 {
            let json = [
                "questionText": "What is your name?"
            ]
            if let item = try? JSONDecoder().decode(Question.self, from: json.toJSONData()) {
                menuViewModel.questions.append(TopQuestionItemViewModel(question: item))
            }
        }

        return menuViewModel
    }
}

class TopQuestionItemViewModel: NSObject, ViewModel, ListDiffable {
    var question: Question

    init(question: Question) {
        self.question = question
    }

    func diffIdentifier() -> NSObjectProtocol {
        return self
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let object = object as? TopQuestionsViewModel {
            return self == object
        }
        return false
    }
}
