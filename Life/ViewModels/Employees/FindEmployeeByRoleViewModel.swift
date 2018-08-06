//
//  HRsViewModel.swift
//  Life
//
//  Created by 123 on 06.08.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import Moya
import RealmSwift
import RxSwift
import RxCocoa

class FindEmployeeByRoleViewModel: NSObject, ViewModel {
    
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
    }

}


// MARK: - Methods
extension FindEmployeeByRoleViewModel {
    
    
}

extension FindEmployeeByRoleViewModel: Mockable {
    typealias T = FindEmployeeByRoleViewModel
    
    static func sample() -> FindEmployeeByRoleViewModel {
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
        
        return FindEmployeeByRoleViewModel(employees: employees)
    }
}

















