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
import RxCocoa

class QuestionnairesViewModel: NSObject, ListDiffable {
    var questionnaires = [QuestionnaireViewModel]()
    var topQuestionnaires = [QuestionnaireViewModel]()
    var popularQuestionnaires = [QuestionnaireViewModel]()

    var minimized = true
    var didLoad = false

    private var offset = 0
    private let rows = 10
    private(set) var canLoadMore = true
    let loading = BehaviorRelay<Bool>(value: false)
    private var usingCached = false

    private let disposeBag = DisposeBag()

    let qestionnairesSubject = PublishSubject<[QuestionnaireViewModel]>()
    let topQuestionnairesSubject = PublishSubject<[QuestionnaireViewModel]>()
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
        returnQuestionnairesFromCache(completion: completion, type: .top3)

        provider
            .rx
            .request(.questionnaires)
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                self.didLoad = true

                switch response {
                case .success(let json):
                    if let questionnaires = try? JSONDecoder().decode([Questionnaire].self, from: json.data) {
                        self.topQuestionnaires = questionnaires.map { QuestionnaireViewModel(questionnaire: $0) }

                        completion(nil)

                        self.updateQuestionnairesCache(questionnaires, type: .top3)
                    } else {
                        completion(nil)
                    }
                    self.topQuestionnairesSubject.onNext(self.topQuestionnaires)
                case .error(let error):
                    completion(error)
                }
            }
            .disposed(by: disposeBag)
    }

    public func getPopularQuestionnaires(completion: @escaping ((Error?) -> Void)) {
        returnQuestionnairesFromCache(completion: completion, type: .popular)

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

                        self.updateQuestionnairesCache(questionnaires, type: .popular)
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

    func reload(_ completion: @escaping ((Error?) -> Void)) {
        fetchNextPage(reset: true, completion)
    }

    func fetchNextPage(
        reset: Bool = false,
        _ completion: @escaping ((Error?) -> Void)) {
        if loading.value {
            completion(nil)
            return
        }

        loading.accept(true)

        if reset {
            offset = 0
        }
        if questionnaires.isEmpty && !self.usingCached {
            returnQuestionnairesFromCache(completion: completion, type: .all)
        }

        provider
            .rx
            .request(
                .questionnairesWithDetails(
                    rows: rows,
                    offset: offset
                ))
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                self.loading.accept(false)

                switch response {
                case .success(let json):
                    if let questionnaireItems = try? JSONDecoder().decode([Questionnaire].self, from: json.data) {
                        let items = questionnaireItems.map { QuestionnaireViewModel(questionnaire: $0) }
                        if !reset && !self.usingCached {
                            self.questionnaires.append(contentsOf: items)
                        } else {
                            self.questionnaires = items
                            self.usingCached = false
                        }

                        self.canLoadMore = items.count >= self.rows
                        if self.canLoadMore {
                            self.offset += 1
                        }

                        completion(nil)

                        if self.questionnaires.count <= self.rows {
                            self.updateQuestionnairesCache(questionnaireItems, type: .all)
                        }
                    } else {
                        self.canLoadMore = false
                        completion(nil)
                    }
                case .error(let error):
                    self.canLoadMore = false
                    completion(error)
                }
            }
            .disposed(by: disposeBag)
    }

    private func returnQuestionnairesFromCache(completion: @escaping ((Error?) -> Void), type: ResultsType) {
        DispatchQueue.global().async {
            do {
                var realm = try App.Realms.default()
                if type == .top3 {
                    realm = try App.Realms.allQuestionnaires()
                } else if type == .popular {
                    realm = try App.Realms.popularQuestionnaires()
                }

                let cachedTaskObjects = realm.objects(QuestionnaireObject.self)

                let cachedTasks = Array(cachedTaskObjects).map { Questionnaire(managedObject: $0) }
                let items = cachedTasks.map { QuestionnaireViewModel(questionnaire: $0) }

                if type == .popular {
                    self.popularQuestionnaires = items
                } else if type == .all {
                    self.questionnaires = items
                    self.usingCached = true
                } else {
                    self.topQuestionnaires = items
                }

                DispatchQueue.main.async {
                    if type == .popular {
                        self.popularQuestionnairesSubject.onNext(items)
                    } else if type == .all {
                        if !items.isEmpty {
                            self.loading.accept(false)
                        }

                        self.qestionnairesSubject.onNext(items)
                    } else {
                        self.topQuestionnairesSubject.onNext(items)
                    }

                    completion(nil)
                }
            } catch let error as NSError {
                print("Failed to access the Realm database with error - \(error.localizedDescription)")
            }
        }
    }

    private func updateQuestionnairesCache(_ questionnaireItems: [Questionnaire], type: ResultsType) {
        DispatchQueue.global().async {
            do {
                var realm = try App.Realms.default()
                if type == .top3 {
                    realm = try App.Realms.allQuestionnaires()
                } else if type == .popular {
                    realm = try App.Realms.popularQuestionnaires()
                }

                realm.beginWrite()
                realm.delete(realm.objects(QuestionnaireObject.self))
                for questionnaire in questionnaireItems {
                    realm.add(questionnaire.managedObject(), update: true)
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
                sample.topQuestionnaires.append(item)
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
