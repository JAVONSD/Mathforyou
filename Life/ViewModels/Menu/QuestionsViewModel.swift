//
//  QuestionsViewModel.swift
//  Life
//
//  Created by Shyngys Kassymov on 22.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import IGListKit
import Moya
import RxSwift

class QuestionsViewModel: NSObject, ViewModel, ListDiffable {
    private(set) var questions = [QuestionItemViewModel]()
    var minimized = true

    private let disposeBag = DisposeBag()

    let questionsSubject = PublishSubject<[QuestionItemViewModel]>()

    private let provider = MoyaProvider<TopQuestionsService>(
        plugins: [
            AuthPlugin(tokenClosure: {
                return User.current.token
            })
        ]
    )

    // MARK: - Methods

    public func getQuestions(completion: @escaping ((Error?) -> Void)) {
        provider
            .rx
            .request(.topQuestions)
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                switch response {
                case .success(let json):
                    if let questions = try? JSONDecoder().decode([Question].self, from: json.data) {
                        self.questions = questions.map { QuestionItemViewModel(question: $0) }

                        completion(nil)
                    } else {
                        completion(nil)
                    }
                    self.questionsSubject.onNext(self.questions)
                case .error(let error):
                    completion(error)
                }
            }
            .disposed(by: disposeBag)
    }

    public func add(question: Question) {
        questions.insert(QuestionItemViewModel(question: question), at: 0)
    }

    public func add(answer: Answer, to questions: [String]) {
        for question in self.questions where questions.contains(question.question.id) {
            question.question.answers.append(answer)
        }
    }

    // MARK: - ListDiffable

    func diffIdentifier() -> NSObjectProtocol {
        return self
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let object = object as? QuestionsViewModel {
            return self == object
        }
        return false
    }
}

extension QuestionsViewModel: Mockable {
    typealias T = QuestionsViewModel

    static func sample() -> QuestionsViewModel {
        let menuViewModel = QuestionsViewModel()

        //swiftlint:disable line_length
        for _ in 0..<10 {
            let json = [
                [
                    "text": "Скажите, как назвать строительную фирму? Не знаем, как можно придумать название своей будущей строительной компании",
                    "authorCode": "00-0234",
                    "authorName": "Вячеслав Иванов",
                    "createDate": "2017-01-14T08:28:04.15",
                    "isLikedByMe": true,
                    "likesQuantity": 453,
                    "viewsQuantity": 23,
                    "answers": [
                        [
                            "createDate": "2018-02-22T08:29:27.523",
                            "authorCode": "00-23452",
                            "authorName": "Айдын Рахимбаев",
                            "text": "От выбора правильного названия компании во многом зависит ее дальнейший успех. Статистика показывает, что красивое название хорошо запоминается, что способствует увеличению числа продаж товаров или услуг. Особенно это важно, если компания работает в строительной сфере.",
                            "isLikedByMe": true,
                            "likesQuantity": 453,
                            "viewsQuantity": 23
                        ]
                    ]],
                [
                    "text": "Which football club you fun for?",
                    "authorCode": "00-000485",
                    "authorName": "Карибекова Сана",
                    "createDate": "2018-02-22T08:28:04.15",
                    "likesQuantity": 100,
                    "viewsQuantity": 12,
                    "answers": [
                        [
                            "createDate": "2018-02-22T08:29:27.523",
                            "authorCode": "00-000485",
                            "authorName": "Карибекова Сана",
                            "text": "Arsenal FC",
                            "likesQuantity": 100,
                            "viewsQuantity": 12
                        ]
                    ]
                ]
            ]
            if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
                let questions = try? JSONDecoder().decode([Question].self, from: jsonData) {
                for question in questions {
                    menuViewModel.questions.append(QuestionItemViewModel(question: question))
                }
            }
        }
        //swiftlint:enable line_length

        return menuViewModel
    }
}

class QuestionItemViewModel: NSObject, ViewModel, ListDiffable {
    var question: Question

    init(question: Question) {
        self.question = question
    }

    func diffIdentifier() -> NSObjectProtocol {
        return NSString(string: self.question.id)
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let object = object as? QuestionItemViewModel {
            return question.id == object.question.id
        }
        return false
    }
}
