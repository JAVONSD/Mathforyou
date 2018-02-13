//
//  ResultsViewModel.swift
//  Life
//
//  Created by Shyngys Kassymov on 13.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import RxSwift

struct ResultViewModel {
    var title: String
    var description: String
    var image: String
}

struct ResultsSectionViewModel {
    var title: String
    var results = [ResultViewModel]()

    init(title: String) {
        self.title = title
    }
}

struct ResultsViewModel {
    var sections = [ResultsSectionViewModel]()
}

extension ResultsViewModel: Mockable {
    typealias T = ResultsViewModel

    static func sample() -> ResultsViewModel {
        var crs = ResultsSectionViewModel(title: NSLocalizedString("corporate_events", comment: ""))
        let cr1 = ResultViewModel(
            title: "BI-марафон",
            description: "17 октября",
            image: ""
        )
        let cr2 = ResultViewModel(
            title: "Астана Марафон",
            description: "21 октября",
            image: ""
        )
        crs.results.append(contentsOf: [cr1, cr2])

        var ers = ResultsSectionViewModel(title: NSLocalizedString("education_and_rewards", comment: ""))
        let er1 = ResultViewModel(
            title: "Сертификат",
            description: "Интуит от 2018",
            image: ""
        )
        let er2 = ResultViewModel(
            title: "Медаль",
            description: "CONGRESS",
            image: ""
        )
        ers.results.append(contentsOf: [er1, er2])

        var ars = ResultsSectionViewModel(title: NSLocalizedString("marks_and_attestations", comment: ""))
        let ar1 = ResultViewModel(
            title: "Курс",
            description: "Повышение квалиф",
            image: ""
        )
        ars.results.append(ar1)

        var resultsViewModel = ResultsViewModel()
        resultsViewModel.sections = [crs, ers, ars]
        return resultsViewModel
    }
}
