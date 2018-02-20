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

        for _ in 0..<5 {
            let json = [
                "fullname": "Фамилия Имя",
                "jobPosition": "Должность"
            ]
            if let employee = try? JSONDecoder().decode(Employee.self, from: json.toJSONData()) {
                let employeeItem = EmployeeViewModel(employee: employee)
                employeesViewModel.employees.append(employeeItem)
            }
        }

        return employeesViewModel
    }
}
