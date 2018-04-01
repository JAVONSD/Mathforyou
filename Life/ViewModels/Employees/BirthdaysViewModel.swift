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

    private(set) var loadingBirthdays = BehaviorRelay<Bool>(value: false)
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
        returnFromCache()

        if loadingBirthdays.value || didLoadBirthdays {
            completion(nil)
            if !loadingBirthdays.value {
                self.employeesToShowSubject.onNext(self.employees)
            }
            return
        }
        loadingBirthdays.accept(true)
        loadingSubject.onNext(true)

        provider
            .rx
            .request(.birthdays)
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                self.loadingBirthdays.accept(false)
                self.loadingSubject.onNext(false)

                switch response {
                case .success(let json):
                    if let employeeItems = try? JSONDecoder().decode([Employee].self, from: json.data) {
                        let items = employeeItems.map { EmployeeViewModel(employee: $0) }
                        self.employees = items
                        self.didLoadBirthdays = true

                        completion(nil)
                        self.employeesToShowSubject.onNext(self.employees)

                        self.updateCache(employeeItems)
                    } else {
                        completion(nil)
                        self.employeesToShowSubject.onNext(self.employees)
                    }
                case .error(let error):
                    completion(error)
                    self.employeesToShowSubject.onNext(self.employees)
                }
            }
            .disposed(by: disposeBag)
    }

    private func returnFromCache() {
        DispatchQueue.global().async {
            do {
                let realm = try App.Realms.birthdays()
                let employeeObjects = realm.objects(EmployeeObject.self)
                if !employeeObjects.isEmpty {
                    let employees = Array(employeeObjects).map { Employee(managedObject: $0) }
                    let employeeViewModels = employees.map { EmployeeViewModel(employee: $0) }

                    self.employees = employeeViewModels

                    self.loadingBirthdays.accept(false)

                    DispatchQueue.main.async {
                        self.employeesToShowSubject.onNext(employeeViewModels)
                    }
                }
            } catch {
                print("Failed to access the Realm database")
            }
        }
    }

    private func updateCache(_ employeeItems: [Employee]) {
        DispatchQueue.global().async {
            do {
                let realm = try App.Realms.birthdays()
                realm.beginWrite()
                for employee in employeeItems {
                    realm.add(employee.managedObject(), update: true)
                }
                for employee in realm.objects(EmployeeObject.self).reversed() {
                    if !employeeItems.contains(Employee(managedObject: employee)),
                        let employeeObject = realm.object(
                            ofType: EmployeeObject.self,
                            forPrimaryKey: employee.code) {
                        realm.delete(employeeObject)
                    }
                }
                try realm.commitWrite()
            } catch {
                print("Failed to access the Realm database")
            }
        }
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
                        || employeeViewModel.employee.workPhoneNumber
                            .removing(chars: [" ", "(", ")", "-"])
                            .lowercased()
                            .contains(text)
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
