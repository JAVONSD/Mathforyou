//
//  VacanciesViewModel.swift
//  Life
//
//  Created by Shyngys Kassymov on 15.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation

struct VacanciesViewModel: ViewModel {
    var vacancies = [VacancyViewModel]()
}

extension VacanciesViewModel: Mockable {
    typealias T = VacanciesViewModel

    static func sample() -> VacanciesViewModel {
        var employeesViewModel = VacanciesViewModel()

        let vacancy = VacancyViewModel(
            vacancy: Vacancy(
                jobPosition: "Начальник Коммерческого Отдела Дивизиона",
                companyName: "Otau Development Group ТОО",
                createDate: "2018-01-30T00:00:00",
                departmentName: "Коммерческий отдел",
                salary: "Не указана"
            )
        )
        for _ in 0..<5 {
            employeesViewModel.vacancies.append(vacancy)
        }

        return employeesViewModel
    }
}

struct VacancyViewModel: ViewModel {
    var vacancy: Vacancy
}
