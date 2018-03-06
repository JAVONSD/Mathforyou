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

class BIBoardViewModel: NSObject, ViewModel {

    private(set) var newsViewModel = NewsViewModel()
    private(set) var suggestionsViewModel = SuggestionsViewModel()
    private(set) var questionnairesViewModel = QuestionnairesViewModel()
    private(set) unowned var stuffViewModel: StuffViewModel
    private(set) unowned var topQuestionsViewModel: TopQuestionsViewModel

    init(stuffViewModel: StuffViewModel,
         topQuestionsViewModel: TopQuestionsViewModel) {
        self.stuffViewModel = stuffViewModel
        self.topQuestionsViewModel = topQuestionsViewModel
    }

}
