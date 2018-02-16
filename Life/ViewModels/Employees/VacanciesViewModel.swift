//
//  VacanciesViewModel.swift
//  Life
//
//  Created by Shyngys Kassymov on 15.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation

struct VacanciesViewModel: ViewModel {
    var employees = [EmployeeViewModel]()
}

extension VacanciesViewModel: Mockable {
    typealias T = VacanciesViewModel

    static func sample() -> VacanciesViewModel {
        var employeesViewModel = VacanciesViewModel()

        let employee = EmployeeViewModel(
            image: "",
            fullName: "Фамилия Имя",
            position: "Должность"
        )
        for _ in 0..<5 {
            employeesViewModel.employees.append(employee)
        }

        return employeesViewModel
    }
}
