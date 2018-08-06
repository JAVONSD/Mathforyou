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
import RealmSwift
import RxSwift
import RxCocoa

class EmployeesViewModel: NSObject, ListDiffable, ViewModel {

    private let disposeBag = DisposeBag()

    private(set) var loading = BehaviorRelay<Bool>(value: false)
    private(set) var didLoadEmployees = false

    let employees = BehaviorRelay<[EmployeeViewModel]>(value: [])
    let filteredEmployees = BehaviorRelay<[EmployeeViewModel]>(value: [])
    var filterText = Observable.just("")

    let onSuccess = PublishSubject<Void>()
    let onError = PublishSubject<Error>()

    private let provider = MoyaProvider<EmployeesService>(
        plugins: [
            AuthPlugin(tokenClosure: {
                return User.current.token
            })
        ]
    )

    convenience init(employees: [EmployeeViewModel]) {
        self.init()
        self.employees.accept(employees)
    }
    
    // MARK: - Methods

    public func getEmployees() {
        // load local phone contacts
        DispatchQueue.global().async {
            _ = ContactsService.shared.contacts
        }

        returnFromCache()

        if loading.value || didLoadEmployees {
            if !loading.value {
                filteredEmployees.accept(employees.value)
            }
            return
        }
        loading.accept(true)

        provider
            .rx
            .request(.employees)
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                self.loading.accept(false)

                switch response {
                case .success(let json):
                    if let jsonData = (try? JSONSerialization.jsonObject(
                            with: json.data,
                            options: []
                        )) as? [String: Any],
                        let list = jsonData["list"] as? [[String: Any]] {
                        self.didLoadEmployees = true

                        //swiftlint:disable force_try
                        let employeeItems = list.map {
                            try! JSONDecoder().decode(Employee.self, from: $0.toJSONData())
                        }
                        //swiftlint:enable force_try

                        let items = employeeItems.map { EmployeeViewModel(employee: $0) }
                        self.employees.accept(items)
                        self.filteredEmployees.accept(items)

                        self.onSuccess.onNext(())

                        self.updateCache(employeeItems)
                    } else {
                        self.filteredEmployees.accept(self.employees.value)
                    }
                case .error(let error):
                    self.filteredEmployees.accept(self.employees.value)
                    self.onError.onNext(error)
                }
            }
            .disposed(by: disposeBag)
    }

    private func returnFromCache() {
        DispatchQueue.global().async {
            do {
                let realm = try App.Realms.default()
                let employeeObjects = realm.objects(EmployeeObject.self)
                if !employeeObjects.isEmpty {
                    let employees = Array(employeeObjects).map { Employee(managedObject: $0) }
                    let employeeViewModels = employees.map { EmployeeViewModel(employee: $0) }

                    self.employees.accept(employeeViewModels)

                    DispatchQueue.main.async {
                        self.loading.accept(false)
                        self.filteredEmployees.accept(employeeViewModels)
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
                let realm = try App.Realms.default()
                realm.beginWrite()
                for employee in employeeItems {
                    if let employeeObject = realm.object(
                        ofType: EmployeeObject.self, forPrimaryKey: employee.code) {
                        employeeObject.update(with: employee)
                    } else {
                        realm.add(employee.managedObject(), update: true)
                    }
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
            filteredEmployees.accept(employees.value)
            return
        }

        DispatchQueue.global().async {
            let text = text.lowercased()

            let filteredEmployees = self.employees.value.filter({ (employeeViewModel) -> Bool in
                return employeeViewModel.employee.filter(by: text)
            })

            DispatchQueue.main.async {
                self.filteredEmployees.accept(filteredEmployees)
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

// MARK: - Employee View Model
class EmployeeViewModel: NSObject, ViewModel, ListDiffable {
    private(set) var employee: Employee
    let employeeVariable = BehaviorRelay<Employee>(
        value: Employee(managedObject: EmployeeObject()))

    private let disposeBag = DisposeBag()

    private let provider = MoyaProvider<EmployeesService>(
        plugins: [
            AuthPlugin(tokenClosure: {
                return User.current.token
            })
        ]
    )

    let contactsService = ContactsService.shared

    init(employee: Employee) {
        self.employee = employee
        employeeVariable.accept(employee)
    }

    // MARK: - Methods

    public func getEmployeeInfo(completion: @escaping ((Error?) -> Void)) {
        returnFromCache()

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
                        self.employee.administrativeChiefName = employee.administrativeChiefName
                        self.employee.functionalChiefName = employee.functionalChiefName
                        self.employeeVariable.accept(self.employee)

                        completion(nil)

                        self.updateCache(employee)
                    } else {
                        completion(nil)
                    }
                case .error(let error):
                    completion(error)
                }
            }
            .disposed(by: disposeBag)
    }

    private func returnFromCache() {
        DispatchQueue.global().async {
            do {
                let realm = try App.Realms.default()
                let employeeObject = realm.object(
                    ofType: EmployeeObject.self, forPrimaryKey: self.employee.code)
                if let employeeObject = employeeObject {
                    let employee = Employee(managedObject: employeeObject)
                    DispatchQueue.main.async {
                        self.employee.login = employee.login
                        self.employee.jobPosition = employee.jobPosition
                        self.employee.company = employee.company
                        self.employee.email = employee.email
                        self.employee.workPhoneNumber = employee.workPhoneNumber
                        self.employee.mobilePhoneNumber = employee.mobilePhoneNumber
                        self.employee.address = employee.address
                        self.employee.isBirthdayToday = employee.isBirthdayToday
                        self.employee.administrativeChiefName = employee.administrativeChiefName
                        self.employee.functionalChiefName = employee.functionalChiefName
                        self.employeeVariable.accept(self.employee)
                    }
                }
            } catch {
                print("Failed to access the Realm database")
            }
        }
    }

    private func updateCache(_ employee: Employee) {
        DispatchQueue.global().async {
            do {
                let realm = try App.Realms.default()
                realm.beginWrite()
                let object = employee.managedObject()
                object.code = self.employee.code
                realm.add(object, update: true)
                try realm.commitWrite()
            } catch {
                print("Failed to access the Realm database")
            }
        }
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







