//
//  LoginViewModel.swift
//  Life
//
//  Created by Shyngys Kassymov on 14.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import RxCocoa

struct LoginViewModel: ViewModel {

    private var loginProvider = MoyaProvider<AuthService>()
    private var disposeBag = DisposeBag()

    var loginErrorMessage = BehaviorRelay<String?>(value: nil)
    var passwordErrorMessage = BehaviorRelay<String?>(value: nil)

    // MARK: - Methods

    public func login(
        _ login: String,
        password: String,
        completion: @escaping ((SingleEvent<Response>) -> Void)) {
        loginProvider
            .rx
            .request(.token(login: login, password: password))
            .filterSuccessfulStatusCodes()
            .subscribe { event in
                completion(event)
            }
            .disposed(by: disposeBag)
    }

}
