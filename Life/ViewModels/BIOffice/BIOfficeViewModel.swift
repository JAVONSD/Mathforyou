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

    private(set) var eventsViewModel = EventsViewModel()
    private(set) unowned var tasksAndRequestsViewModel: TasksAndRequestsViewModel
    private(set) var newsViewModel = NewsViewModel()
    private(set) var kpiViewModel = KPIViewModel()
    private(set) var hrViewModel = HRViewModel()
    private(set) var idpViewModel = IDPViewModel()

    private(set) var suggestionsViewModel = SuggestionsViewModel()
    private(set) var questionnairesViewModel = QuestionnairesViewModel()
    private(set) unowned var topQuestionsViewModel: TopQuestionsViewModel

    init(tasksAndRequestsViewModel: TasksAndRequestsViewModel,
         topQuestionsViewModel: TopQuestionsViewModel) {
        self.tasksAndRequestsViewModel = tasksAndRequestsViewModel
        self.topQuestionsViewModel = topQuestionsViewModel
    }

}
