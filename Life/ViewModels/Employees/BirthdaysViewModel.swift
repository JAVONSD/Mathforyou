//
//  BirthdaysViewModel.swift
//  Life
//
//  Created by Shyngys Kassymov on 15.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation

struct BirthdaysViewModel: ViewModel {
    var employees = [EmployeeViewModel]()
}

extension BirthdaysViewModel: Mockable {
    typealias T = BirthdaysViewModel

    static func sample() -> BirthdaysViewModel {
        var employeesViewModel = BirthdaysViewModel()

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
