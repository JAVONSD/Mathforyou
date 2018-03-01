//
//  BirthdaysViewModel.swift
//  Life
//
//  Created by Shyngys Kassymov on 15.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import RxCocoa

class BirthdaysViewModel: NSObject, ViewModel {

    private(set) var employees = [EmployeeViewModel]()

    private let loadingSubject = PublishSubject<Bool>()
    var loading: Observable<Bool> { return loadingSubject.asObservable() }

    private(set) var loadingBirthdays = false
    private(set) var didLoadBirthdays = false

    private let disposeBag = DisposeBag()

    private let employeesToShowSubject = PublishSubject<[EmployeeViewModel]>()
    var employeesToShow: Observable<[EmployeeViewModel]> { return employeesToShowSubject.asObservable() }

    let filterText = BehaviorRelay(value: "")

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

    public func getBirthdays(completion: @escaping ((Error?) -> Void)) {
        if loadingBirthdays || didLoadBirthdays {
            completion(nil)
            if !loadingBirthdays {
                self.employeesToShowSubject.onNext(self.employees)
            }
            return
        }
        loadingBirthdays = true
        loadingSubject.onNext(true)

        provider
            .rx
            .request(.birthdays)
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                self.loadingBirthdays = false
                self.loadingSubject.onNext(false)

                switch response {
                case .success(let json):
                    if let lentaItems = try? JSONDecoder().decode([Employee].self, from: json.data) {
                        let items = lentaItems.map { EmployeeViewModel(employee: $0) }
                        self.employees = items
                        self.didLoadBirthdays = true

                        completion(nil)
                    } else {
                        completion(nil)
                    }
                    self.employeesToShowSubject.onNext(self.employees)
                case .error(let error):
                    completion(error)
                    self.employeesToShowSubject.onNext(self.employees)
                }
            }
            .disposed(by: disposeBag)
    }

    public func filter(with text: String) {
        if text.isEmpty {
            employeesToShowSubject.onNext(employees)
            return
        }

        DispatchQueue.global().async {
            let text = text.lowercased()
            let filteredEmployees = self.employees.filter({ (employeeViewModel) -> Bool in
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
                self.employeesToShowSubject.onNext(filteredEmployees)
            }
        }
    }

}

extension BirthdaysViewModel: Mockable {
    typealias T = BirthdaysViewModel

    static func sample() -> BirthdaysViewModel {
        var employees = [EmployeeViewModel]()
        for _ in 0..<5 {
            let json = [
                "fullname": "Фамилия Имя",
                "jobPosition": "Должность"
            ]
            if let employee = try? JSONDecoder().decode(Employee.self, from: json.toJSONData()) {
                let employeeItem = EmployeeViewModel(employee: employee)
                employees.append(employeeItem)
            }
        }

        return BirthdaysViewModel(employees: employees)
    }
}
