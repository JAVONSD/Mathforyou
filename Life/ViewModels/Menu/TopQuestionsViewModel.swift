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
    var questions = QuestionsViewModel()
    var answers = AnswersViewModel()
    var minimized = true

    var topAnswerAuthors: [AnswerAuthorViewModel] {
        let answersSortedByLikes = answers.answers.sorted { (ans1, ans2) -> Bool in
            return ans1.answer.likesQuantity > ans2.answer.likesQuantity
        }
        let videoAnswersSortedByLikes = answers.videoAnswers.sorted { (ans1, ans2) -> Bool in
            return ans1.answer.likesQuantity > ans2.answer.likesQuantity
        }
        var allAnswers = answersSortedByLikes + videoAnswersSortedByLikes
        allAnswers.sort { (ans1, ans2) -> Bool in
            return ans1.answer.likesQuantity > ans2.answer.likesQuantity
        }

        return allAnswers.map({ (answerViewModel) in
            var data = [String: Any]()
            data["code"] = answerViewModel.answer.authorCode
            data["name"] = answerViewModel.answer.authorName
            data["jobPosition"] = answerViewModel.answer.jobPosition
            data["answersQuantity"] = answerViewModel.answer.answersQuantity
            data["likesQuantity"] = answerViewModel.answer.likesQuantity
            data["viewsQuantity"] = answerViewModel.answer.viewsQuantity
            data["isLikedByMe"] = answerViewModel.answer.isLikedByMe
            let author = try? JSONDecoder().decode(AnswerAuthor.self, from: data.toJSONData())
            return AnswerAuthorViewModel(author: author!)
        })
    }

    // MARK: - ListDiffable

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
        let sample = TopQuestionsViewModel()

        sample.questions = QuestionsViewModel.sample()
        sample.answers = AnswersViewModel.sample()

        return sample
    }
}
