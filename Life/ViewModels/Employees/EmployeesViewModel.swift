//
//  EmployeesViewModel.swift
//  Life
//
//  Created by Shyngys Kassymov on 14.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation

struct EmployeesViewModel: ViewModel {
    var employees = [EmployeeViewModel]()
}

extension EmployeesViewModel: Mockable {
    typealias T = EmployeesViewModel

    static func sample() -> EmployeesViewModel {
        var employeesViewModel = EmployeesViewModel()

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
