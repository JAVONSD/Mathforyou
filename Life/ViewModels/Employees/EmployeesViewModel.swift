//
//  EmployeesViewModel.swift
//  Life
//
//  Created by Shyngys Kassymov on 14.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import IGListKit
import Moya
import RxSwift

class EmployeesViewModel: NSObject, ListDiffable, ViewModel {
    private(set) var employees = [EmployeeViewModel]()
    private(set) var filteredEmployees = [EmployeeViewModel]()
    var minimized = true

    private(set) var loading = false
    private(set) var canLoadMore = true

    private let disposeBag = DisposeBag()

    let itemsChangeSubject = PublishSubject<[EmployeeViewModel]>()
    var filterText = Observable.just("")

    private let provider = MoyaProvider<EmployeesService>(
        plugins: [
            AuthPlugin(tokenClosure: {
                return User.current.token
            })
        ]
    )

    convenience init(employees: [EmployeeViewModel]) {
        self.init()
        self.employees = employees
    }

    // MARK: - Methods

    public func getEmployees(completion: @escaping ((Error?) -> Void)) {
        provider
            .rx
            .request(.employees)
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                self.loading = false
                self.canLoadMore = false

                switch response {
                case .success(let json):
                    if let jsonData = (try? JSONSerialization.jsonObject(
                            with: json.data,
                            options: []
                        )) as? [String: Any],
                        let list = jsonData["list"] as? [[String: Any]] {
                        //swiftlint:disable force_try
                        let lentaItems = list.map {
                            try! JSONDecoder().decode(Employee.self, from: $0.toJSONData())
                        }
                        //swiftlint:enable force_try
                        let items = lentaItems.map { EmployeeViewModel(employee: $0) }
                        self.employees = items
                        self.filteredEmployees = items

                        completion(nil)
                    } else {
                        completion(nil)
                    }
                    self.itemsChangeSubject.onNext(self.employees)
                case .error(let error):
                    completion(error)
                    self.itemsChangeSubject.onNext(self.employees)
                }
            }
            .disposed(by: disposeBag)
    }

    public func filter(with text: String) {
        if text.isEmpty {
            itemsChangeSubject.onNext(employees)
            return
        }

        DispatchQueue.global().async {
            let text = text.lowercased()

            self.filteredEmployees = self.employees.filter({ (employeeViewModel) -> Bool in
                var include = false
                include = include
                    || employeeViewModel.employee.fullname.lowercased().contains(text)
                if !include {
                    include = include
                        || employeeViewModel.employee.firstname.lowercased().contains(text)
                }
                if !include {
                    include = include
                        || employeeViewModel.employee.login.lowercased().contains(text)
                }
                if !include {
                    include = include
                        || employeeViewModel.employee.jobPosition.lowercased().contains(text)
                }
                if !include {
                    include = include
                        || employeeViewModel.employee.company.lowercased().contains(text)
                }
                if !include {
                    include = include
                        || employeeViewModel.employee.companyName.lowercased().contains(text)
                }
                if !include {
                    include = include
                        || employeeViewModel.employee.departmentName.lowercased().contains(text)
                }
                if !include {
                    include = include
                        || employeeViewModel.employee.address.lowercased().contains(text)
                }
                if !include {
                    include = include
                        || employeeViewModel.employee.workPhoneNumber.lowercased().contains(text)
                }
                if !include {
                    include = include
                        || employeeViewModel.employee.mobilePhoneNumber.lowercased().contains(text)
                }

                return include
            })

            DispatchQueue.main.async {
                self.itemsChangeSubject.onNext(self.filteredEmployees)
            }
        }
    }

    // MARK: - ListDiffable

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
        var employees = [EmployeeViewModel]()
        for _ in 0..<2 {
            let json = [
                "fullname": "Фамилия Имя",
                "jobPosition": "Должность"
            ]
            if let suggestion = try? JSONDecoder().decode(Employee.self, from: json.toJSONData()) {
                let item = EmployeeViewModel(employee: suggestion)
                employees.append(item)
            }
        }

        return EmployeesViewModel(employees: employees)
    }
}

class EmployeeViewModel: NSObject, ViewModel, ListDiffable {
    private(set) var employee: Employee

    private let disposeBag = DisposeBag()

    private let provider = MoyaProvider<EmployeesService>(
        plugins: [
            AuthPlugin(tokenClosure: {
                return User.current.token
            })
        ]
    )

    init(employee: Employee) {
        self.employee = employee
    }

    // MARK: - Methods

    public func getEmployeeInfo(completion: @escaping ((Error?) -> Void)) {
        provider
            .rx
            .request(.employeeInfo(code: employee.code))
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                switch response {
                case .success(let json):
                    if let employee = try? JSONDecoder().decode(Employee.self, from: json.data) {
                        self.employee.login = employee.login
                        self.employee.jobPosition = employee.jobPosition
                        self.employee.company = employee.company
                        self.employee.email = employee.email
                        self.employee.workPhoneNumber = employee.workPhoneNumber
                        self.employee.mobilePhoneNumber = employee.mobilePhoneNumber
                        self.employee.address = employee.address
                        self.employee.isBirthdayToday = employee.isBirthdayToday

                        completion(nil)
                    } else {
                        completion(nil)
                    }
                case .error(let error):
                    completion(error)
                }
            }
            .disposed(by: disposeBag)
    }

    // MARK: - ListDiffable

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
