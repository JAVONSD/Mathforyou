//
//  QuestionnairesViewModel.swift
//  Life
//
//  Created by Shyngys Kassymov on 19.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import IGListKit
import Moya
import RealmSwift
import RxSwift

class QuestionnairesViewModel: NSObject, ListDiffable {
    var questionnaires = [QuestionnaireViewModel]()
    var popularQuestionnaires = [QuestionnaireViewModel]()
    var minimized = true

    private let disposeBag = DisposeBag()

    let questionnairesSubject = PublishSubject<[QuestionnaireViewModel]>()
    let popularQuestionnairesSubject = PublishSubject<[QuestionnaireViewModel]>()

    private let provider = MoyaProvider<QuestionnairesService>(
        plugins: [
            AuthPlugin(tokenClosure: {
                return User.current.token
            })
        ]
    )

    // MARK: - Methods

    public func getQuestionnaires(completion: @escaping ((Error?) -> Void)) {
        returnQuestionnairesFromCache(completion: completion, isPopular: false)

        provider
            .rx
            .request(.questionnaires)
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                switch response {
                case .success(let json):
                    if let questionnaires = try? JSONDecoder().decode([Questionnaire].self, from: json.data) {
                        self.questionnaires = questionnaires.map { QuestionnaireViewModel(questionnaire: $0) }

                        completion(nil)

                        self.updateQuestionnairesCache(questionnaires, isPopular: false)
                    } else {
                        completion(nil)
                    }
                    self.questionnairesSubject.onNext(self.questionnaires)
                case .error(let error):
                    completion(error)
                }
            }
            .disposed(by: disposeBag)
    }

    public func getPopularQuestionnaires(completion: @escaping ((Error?) -> Void)) {
        returnQuestionnairesFromCache(completion: completion, isPopular: true)

        provider
            .rx
            .request(.popularQuestionnaires)
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                switch response {
                case .success(let json):
                    if let questionnaires = try? JSONDecoder().decode([Questionnaire].self, from: json.data) {
                        self.popularQuestionnaires = questionnaires.map {
                            QuestionnaireViewModel(questionnaire: $0)
                        }

                        completion(nil)

                        self.updateQuestionnairesCache(questionnaires, isPopular: true)
                    } else {
                        completion(nil)
                    }
                    self.popularQuestionnairesSubject.onNext(self.popularQuestionnaires)
                case .error(let error):
                    completion(error)
                }
            }
            .disposed(by: disposeBag)
    }

    private func returnQuestionnairesFromCache(completion: @escaping ((Error?) -> Void), isPopular: Bool) {
        DispatchQueue.global().async {
            do {
                let realm = isPopular
                    ? try App.Realms.popularQuestionnaires()
                    : try App.Realms.default()
                let cachedTaskObjects = realm.objects(QuestionnaireObject.self)

                let cachedTasks = Array(cachedTaskObjects).map { Questionnaire(managedObject: $0) }
                let items = cachedTasks.map { QuestionnaireViewModel(questionnaire: $0) }

                if isPopular {
                    self.popularQuestionnaires = items
                } else {
                    self.questionnaires = items
                }

                DispatchQueue.main.async {
                    completion(nil)

                    if isPopular {
                        self.popularQuestionnairesSubject.onNext(items)
                    } else {
                        self.questionnairesSubject.onNext(items)
                    }
                }
            } catch let error as NSError {
                print("Failed to access the Realm database with error - \(error.localizedDescription)")
            }
        }
    }

    private func updateQuestionnairesCache(_ questionnaireItems: [Questionnaire], isPopular: Bool) {
        DispatchQueue.global().async {
            do {
                let realm = isPopular
                    ? try App.Realms.popularQuestionnaires()
                    : try App.Realms.default()
                realm.beginWrite()
                for questionnaire in questionnaireItems {
                    realm.add(questionnaire.managedObject(), update: true)
                }
                for questionnaireObject in realm.objects(QuestionnaireObject.self).reversed() {
                    if !questionnaireItems.contains(Questionnaire(managedObject: questionnaireObject)),
                        let questionnaireObjectToDelete = realm.object(
                            ofType: QuestionnaireObject.self,
                            forPrimaryKey: questionnaireObject.id) {
                        realm.delete(questionnaireObjectToDelete)
                    }
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
