//
//  RequestFormViewModel.swift
//  Life
//
//  Created by Shyngys Kassymov on 03.03.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import IGListKit
import Moya
import RxSwift

class RequestFormViewModel: NSObject {

    private(set) var category: Request.Category

    private let disposeBag = DisposeBag()

    let requestCreateIsPendingSubject = PublishSubject<Bool>()
    let requestCreatedSubject = PublishSubject<Int>()
    let requestCreatedWithErrorSubject = PublishSubject<Error>()

    let requestText = BehaviorSubject<String>(value: "")
    let dueDate = BehaviorSubject<Date>(value: Date())
    let attachments = BehaviorSubject<[URL]>(value: [])

    private let provider = MoyaProvider<RequestsService>(
        plugins: [
            AuthPlugin(tokenClosure: {
                return User.current.token
            })
        ]
    )

    init(category: Request.Category) {
        self.category = category
    }

    // MARK: - Methods

    public func createRequest() {
        guard let dueDate = try? dueDate.value(),
            let description = try? requestText.value(),
            let attachments = try? attachments.value() else {
            return
        }

        requestCreateIsPendingSubject.onNext(true)
        provider
            .rx
            .request(.createRequest(
                dueDate: dueDate.serverDate,
                description: description,
                attachments: attachments
                ))
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                self.requestCreateIsPendingSubject.onNext(false)
                switch response {
                case .success(let json):
                    self.requestCreatedSubject.onNext(json.statusCode)
                case .error(let error):
                    self.requestCreatedWithErrorSubject.onNext(error)
                }
            }
            .disposed(by: disposeBag)
    }

}
