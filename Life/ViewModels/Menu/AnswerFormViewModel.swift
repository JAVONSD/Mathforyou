//
//  AnswerFormViewModel.swift
//  Life
//
//  Created by Shyngys Kassymov on 09.03.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import IGListKit
import Moya
import RxSwift
import RxCocoa

class AnswerFormViewModel: NSObject, ViewModel {

    private(set) var questions: [Question]
    private(set) var isVideo: Bool

    private let disposeBag = DisposeBag()

    let isLoadingSubject = BehaviorSubject<Bool>(value: false)
    let errorSubject = PublishSubject<Error>()
    let answerCreatedSubject = PublishSubject<Answer>()
    let videoAnswerCreatedSubject = PublishSubject<Void>()

    let pickedQuestions = BehaviorRelay<Set<Question>>(value: [])
    let answerText = BehaviorRelay<String>(value: "")
    var videoFile: URL?

    private let topQuestionsProvider = MoyaProvider<TopQuestionsService>(
        plugins: [
            AuthPlugin(tokenClosure: {
                return User.current.token
            })
        ]
    )

    init(questions: [Question], isVideo: Bool) {
        self.questions = questions
        self.isVideo = isVideo
    }

    // MARK: - Methods

    public func createAnswer() {
        var request = TopQuestionsService.addAnswer(
            id: pickedQuestions.value.first?.id ?? "",
            answerText: answerText.value
        )
        if isVideo,
            let videoFile = videoFile {
            request = TopQuestionsService.addVideoAnswer(
                ids: pickedQuestions.value.map { $0.id },
                videoFile: videoFile
            )
        }

        isLoadingSubject.onNext(true)
        topQuestionsProvider
            .rx
            .request(request)
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                self.isLoadingSubject.onNext(false)
                switch response {
                case .success(let json):
                    if let answer = try? JSONDecoder().decode(Answer.self, from: json.data) {
                        self.answerCreatedSubject.onNext(answer)
                    } else if json.statusCode == 200 {
                        self.videoAnswerCreatedSubject.onNext(())
                    }
                case .error(let error):
                    self.errorSubject.onNext(error)
                }
            }
            .disposed(by: disposeBag)
    }

}
