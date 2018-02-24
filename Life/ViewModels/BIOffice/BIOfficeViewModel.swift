//
//  BIOfficeViewModel.swift
//  Life
//
//  Created by Shyngys Kassymov on 14.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import RxCocoa

struct BIOfficeViewModel: ViewModel {

    // debug
    var eventsViewModel = EventsViewModel.sample()
    var tasksAndRequestsViewModel = TasksAndRequestsViewModel()

    var kpiViewModel = KPIViewModel()
    var sbvViewModel = SBViewModel()
    var idpViewModel = IDPViewModel()

    private var disposeBag = DisposeBag()

    private let provider = MoyaProvider<UserProfileService>(plugins: [AuthPlugin(tokenClosure: {
        return User.current.token
    })])

    // MARK: - Methods

    public func syncUserProfile(onUnauthorizedError: @escaping (() -> Void)) {
        provider
            .rx
            .request(.userProfile)
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                switch response {
                case .success(let json):
                    if let profile = try? JSONDecoder().decode(UserProfile.self, from: json.data) {
                        User.current.profile = profile
                        User.current.save()
                    }
                case .error(let error):
                    if let moyaError = error as? MoyaError,
                        moyaError.response?.statusCode == 401 {
                        onUnauthorizedError()
                    }
                }
            }
            .disposed(by: disposeBag)
    }

}
