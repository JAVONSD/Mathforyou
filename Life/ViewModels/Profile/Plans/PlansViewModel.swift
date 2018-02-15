//
//  PlansViewModel.swift
//  Life
//
//  Created by Shyngys Kassymov on 13.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation

struct PlansViewModel: ViewModel {
    var sections = [PlansSectionViewModel]()
}

extension PlansViewModel: Mockable {
    typealias T = PlansViewModel

    static func sample() -> PlansViewModel {
        var plansViewModel = PlansViewModel()

        let kpi1 = PlanViewModel(
            title: "Рост прибыли",
            description: "Цель"
        )
        let kpi2 = PlanViewModel(
            title: "Two-line item",
            description: "Secondary"
        )
        var kpiSection = PlansSectionViewModel(title: NSLocalizedString("kpi", comment: ""))
        kpiSection.plans = [kpi1, kpi2]

        let idp1 = PlanViewModel(
            title: "Two-line item",
            description: "Secondary"
        )
        let idp2 = PlanViewModel(
            title: "Two-line item",
            description: "Secondary"
        )
        var idpSection = PlansSectionViewModel(title: NSLocalizedString("ind_dev_plan", comment: ""))
        idpSection.plans = [idp1, idp2]

        let vacation1 = PlanViewModel(
            title: "Two-line item",
            description: "Secondary"
        )
        var vacationSection = PlansSectionViewModel(title: NSLocalizedString("vacation_dates", comment: ""))
        vacationSection.plans = [vacation1]

        plansViewModel.sections = [kpiSection, idpSection, vacationSection]

        return plansViewModel
    }
}

struct PlansSectionViewModel: ViewModel {
    var title: String
    var plans = [PlanViewModel]()

    init(title: String) {
        self.title = title
    }
}

struct PlanViewModel: ViewModel {
    var title: String
    var description: String
}
