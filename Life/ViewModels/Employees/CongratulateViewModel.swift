//
//  CongratulateViewModel.swift
//  Life
//
//  Created by Shyngys Kassymov on 02.04.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import RxCocoa

class CongratulateViewModel {

    let employee: Employee

    private let disposeBag = DisposeBag()

    let loading = BehaviorRelay<Bool>(value: false)
    let text = BehaviorRelay<String>(value: "")

    let onSuccessSubject = PublishSubject<Void>()
    let onErrorSubject = PublishSubject<Error>()

    private let provider = MoyaProvider<EmployeesService>(
        plugins: [
            AuthPlugin(tokenClosure: {
                return User.current.token
            })
        ]
    )

    init(employee: Employee) {
        self.employee = employee
    }

    // MARK: - Methods

    public func congratulate() {
        loading.accept(true)

        provider.rx.request(.congratulate(code: User.current.employeeCode, text: text.value))
            .filterSuccessfulStatusCodes()
            .subscribe { [weak self] response in
                guard let `self` = self else { return }

                self.loading.accept(false)

                switch response {
                case .success:
                    self.onSuccessSubject.onNext(())
                case .error(let error):
                    self.onErrorSubject.onNext(error)
                }
            }
            .disposed(by: disposeBag)
    }

}
