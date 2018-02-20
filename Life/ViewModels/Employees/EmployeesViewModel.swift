//
//  EmployeesViewModel.swift
//  Life
//
//  Created by Shyngys Kassymov on 14.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import IGListKit

class EmployeesViewModel: NSObject, ListDiffable, ViewModel {
    var employees = [EmployeeViewModel]()
    var minimized = true

    func diffIdentifier() -> NSObjectProtocol {
        return self
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let item = object as? EmployeesViewModel {
            return self == item
        }
        return false
    }
}

extension EmployeesViewModel: Mockable {
    typealias T = EmployeesViewModel

    static func sample() -> EmployeesViewModel {
        let employeesViewModel = EmployeesViewModel()

        for _ in 0..<2 {
            let json = [
                "fullname": "Test employee"
            ]
            if let suggestion = try? JSONDecoder().decode(Employee.self, from: json.toJSONData()) {
                let item = EmployeeViewModel(employee: suggestion)
                employeesViewModel.employees.append(item)
            }
        }

        return employeesViewModel
    }
}

class EmployeeViewModel: NSObject, ListDiffable {
    var employee: Employee

    init(employee: Employee) {
        self.employee = employee
    }

    func diffIdentifier() -> NSObjectProtocol {
        return NSString(string: employee.code)
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let item = object as? EmployeeViewModel {
            return employee.code == item.employee.code
        }
        return false
    }
}
