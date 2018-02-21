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
        var vacanciesViewModel = VacanciesViewModel()

        for _ in 0..<5 {
            let json = [
                "id": UUID().uuidString,
                "jobPosition": "Начальник Коммерческого Отдела Дивизиона",
                "companyName": "Otau Development Group ТОО",
                "createDate": "2018-01-30T00:00:00",
                "departmentName": "Коммерческий отдел",
                "salary": "Не указана"
            ]
            if let vacancy = try? JSONDecoder().decode(Vacancy.self, from: json.toJSONData()) {
                let vacancyViewModel = VacancyViewModel(vacancy: vacancy)
                vacanciesViewModel.vacancies.append(vacancyViewModel)
            }
        }

        return vacanciesViewModel
    }
}

struct VacancyViewModel: ViewModel {
    var vacancy: Vacancy
}
