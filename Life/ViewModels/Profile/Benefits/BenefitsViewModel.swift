//
//  BenefitsViewModel.swift
//  Life
//
//  Created by Shyngys Kassymov on 13.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation

struct BenefitsViewModel {
    var sections = [BenefitsSectionViewModel]()
}

extension BenefitsViewModel: Mockable {
    typealias T = BenefitsViewModel

    static func sample() -> BenefitsViewModel {
        var benefitsViewModel = BenefitsViewModel()

        let fitness1 = BenefitViewModel(
            title: "Two-line item",
            description: "Secondary",
            images: []
        )
        let fitness2 = BenefitViewModel(
            title: "Two-line item",
            description: "Secondary",
            images: []
        )
        var fitnessSection = BenefitsSectionViewModel(title: NSLocalizedString("fitness", comment: ""))
        fitnessSection.benefits = [fitness1, fitness2]

        let acc1 = BenefitViewModel(
            title: "Two-line item",
            description: "Secondary",
            images: []
        )
        var accSection = BenefitsSectionViewModel(title: NSLocalizedString("accommodation", comment: ""))
        accSection.benefits = [acc1]

        let biClub1 = BenefitViewModel(
            title: "",
            description: "",
            images: ["", "", "", "", "", ""]
        )
        var biClubSection = BenefitsSectionViewModel(title: NSLocalizedString("bi_club", comment: ""))
        biClubSection.benefits = [biClub1]

        benefitsViewModel.sections = [fitnessSection, accSection, biClubSection]

        return benefitsViewModel
    }
}

struct BenefitsSectionViewModel {
    var title: String
    var benefits = [BenefitViewModel]()

    init(title: String) {
        self.title = title
    }
}

struct BenefitViewModel {
    var title: String
    var description: String
    var images = [String]()
}
