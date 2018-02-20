//
//  BIBoardViewModel.swift
//  Life
//
//  Created by Shyngys Kassymov on 14.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import RxCocoa

struct BIBoardViewModel: ViewModel {

    // debug
    var newsViewModel = NewsViewModel.sample()
    var suggestionsViewModel = SuggestionsViewModel.sample()
    var questionnairesViewModel = QuestionnairesViewModel.sample()
    var employeesViewModel = EmployeesViewModel.sample()
    var topQuestionsViewModel = TopQuestionsViewModel.sample()

    private var disposeBag = DisposeBag()

    private let provider = MoyaProvider<UserProfileService>(plugins: [AuthPlugin(tokenClosure: {
        return User.current.token
    })])

    // MARK: - Methods

}
