//
//  HRsViewModel.swift
//  Life
//
//  Created by 123 on 06.08.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxCocoa
import Moya
import Moya_ModelMapper
import RxOptional
import Mapper


struct FindEmployeeByRoleViewModel {
    
//    private(set) var loading = BehaviorRelay<Bool>(value: false)
//    private(set) var didLoadEmployees = false
//
//    let employees = BehaviorRelay<[EmployeeViewModel]>(value: [])
//    let filteredEmployees = BehaviorRelay<[EmployeeViewModel]>(value: [])
//
//    var filterText = Observable.just("")
//
//    let onSuccess = PublishSubject<Void>()
//    let onError = PublishSubject<Error>()
    
    //---------
    private let disposeBag = DisposeBag()
    private let provider = MoyaProvider<EmployeesService>(
        plugins: [
            AuthPlugin(tokenClosure: {
                return User.current.token
            })
        ]
    )
    
    let hrName: Observable<String>
    

}


// MARK: - Methods
extension FindEmployeeByRoleViewModel {
    
   
}

extension FindEmployeeByRoleViewModel {
  
}



















