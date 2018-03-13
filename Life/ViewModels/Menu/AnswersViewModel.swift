//
//  AnswersViewModel.swift
//  Life
//
//  Created by Shyngys Kassymov on 22.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import IGListKit
import Moya
import RealmSwift
import RxSwift

class AnswersViewModel: NSObject, ViewModel, ListDiffable {
    private(set) var answers = [AnswerViewModel]()
    private(set) var videoAnswers = [AnswerViewModel]()
    var minimized = true

    private let disposeBag = DisposeBag()

    let answersSubject = PublishSubject<[AnswerViewModel]>()
    let videoAnswersSubject = PublishSubject<[AnswerViewModel]>()

    private let provider = MoyaProvider<TopQuestionsService>(
        plugins: [
            AuthPlugin(tokenClosure: {
                return User.current.token
            })
        ]
    )

    // MARK: - Methods

    public func getAnswers(completion: @escaping ((Error?) -> Void)) {
        returnAnswersFromCache(completion: completion, isVideo: false)

        provider
            .rx
            .request(.answers)
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                switch response {
                case .success(let json):
                    if let answers = try? JSONDecoder().decode([Answer].self, from: json.data) {
                        self.answers = answers.map { AnswerViewModel(answer: $0) }

                        completion(nil)

                        self.updateAnswersCache(answers, isVideo: false)
                    } else {
                        completion(nil)
                    }
                    self.answersSubject.onNext(self.answers)
                case .error(let error):
                    completion(error)
                }
            }
            .disposed(by: disposeBag)
    }

    public func getVideoAnswers(completion: @escaping ((Error?) -> Void)) {
        returnAnswersFromCache(completion: completion, isVideo: true)

        provider
            .rx
            .request(.videoAnswers)
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                switch response {
                case .success(let json):
                    if let answers = try? JSONDecoder().decode([Answer].self, from: json.data) {
                        self.videoAnswers = answers.map { AnswerViewModel(answer: $0) }

                        completion(nil)

                        self.updateAnswersCache(answers, isVideo: true)
                    } else {
                        completion(nil)
                    }
                    self.videoAnswersSubject.onNext(self.videoAnswers)
                case .error(let error):
                    completion(error)
                }
            }
            .disposed(by: disposeBag)
    }

    private func returnAnswersFromCache(completion: @escaping ((Error?) -> Void), isVideo: Bool) {
        DispatchQueue.global().async {
            do {
                let realm = isVideo
                    ? try App.Realms.videoAnswers()
                    : try App.Realms.answers()
                let cachedAnswerObjects = realm.objects(AnswerObject.self)

                let cachedAnswers = Array(cachedAnswerObjects).map { Answer(managedObject: $0) }
                let items = cachedAnswers.map { AnswerViewModel(answer: $0) }

                if isVideo {
                    self.videoAnswers = items
                } else {
                    self.answers = items
                }

                DispatchQueue.main.async {
                    completion(nil)

                    if isVideo {
                        self.videoAnswersSubject.onNext(items)
                    } else {
                        self.answersSubject.onNext(items)
                    }
                }
            } catch let error as NSError {
                print("Failed to access the Realm database with error - \(error.localizedDescription)")
            }
        }
    }

    private func updateAnswersCache(_ answerItems: [Answer], isVideo: Bool) {
        DispatchQueue.global().async {
            do {
                let realm = isVideo
                    ? try App.Realms.videoAnswers()
                    : try App.Realms.answers()
                realm.beginWrite()
                realm.delete(realm.objects(AnswerObject.self))
                for answer in answerItems {
                    realm.add(answer.managedObject(), update: true)
                }
                try realm.commitWrite()
            } catch {
                print("Failed to access the Realm database")
            }
        }
    }

    // MARK: - ListDiffable

    func diffIdentifier() -> NSObjectProtocol {
        return self
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let object = object as? AnswersViewModel {
            return self == object
        }
        return false
    }
}

extension AnswersViewModel: Mockable {
    typealias T = AnswersViewModel

    static func sample() -> AnswersViewModel {
        let menuViewModel = AnswersViewModel()

        //swiftlint:disable line_length
        for _ in 0..<5 {
            let json = [
                [
                    "questionText": "What is your favourite football club?",
                    "text": "Arsenal FC",
                    "authorCode": "4asdf",
                    "authorName": "Nursultan N.",
                    "jobPosition": "Инженер",
                    "answersQuantity": 1,
                    "likesQuantity": 100,
                    "viewsQuantity": 12,
                    "isLikedByMe": false
                ],
                [
                    "questionText": "Скажите, как назвать строительную фирму? Не знаем, как можно придумать название своей будущей строительной компании",
                    "text": "От выбора правильного названия компании во многом зависит ее дальнейший успех. Статистика показывает, что красивое название хорошо запоминается, что способствует увеличению числа продаж товаров или услуг. Особенно это важно, если компания работает в строительной сфере.",
                    "authorCode": "asdqwe",
                    "authorName": "Айдын Рахимбаев",
                    "jobPosition": "Председатель совета директоров",
                    "answersQuantity": 1,
                    "likesQuantity": 453,
                    "viewsQuantity": 23,
                    "isLikedByMe": true
                ]
            ]
            if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
                let answers = try? JSONDecoder().decode([Answer].self, from: jsonData) {
                for answer in answers {
                    menuViewModel.answers.append(AnswerViewModel(answer: answer))
                }
            }
        }
        //swiftlint:enable line_length

        return menuViewModel
    }
}

class AnswerViewModel: NSObject, ViewModel, ListDiffable {
    var answer: Answer

    init(answer: Answer) {
        self.answer = answer
    }

    func diffIdentifier() -> NSObjectProtocol {
        return NSString(string: self.answer.id)
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let object = object as? AnswerViewModel {
            return answer.id == object.answer.id
        }
        return false
    }
}

class AnswerAuthorViewModel: NSObject, ViewModel, ListDiffable {
    var author: AnswerAuthor

    init(author: AnswerAuthor) {
        self.author = author
    }

    func diffIdentifier() -> NSObjectProtocol {
        return NSString(string: author.code)
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let object = object as? AnswerAuthorViewModel {
            return author.code == object.author.code
        }
        return false
    }
}
