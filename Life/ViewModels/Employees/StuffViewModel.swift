//
//  StuffViewModel.swift
//  Life
//
//  Created by Shyngys Kassymov on 01.03.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import IGListKit
import RxSwift
import RxCocoa

class StuffViewModel: NSObject, ListDiffable {

    private(set) var employeesViewModel = EmployeesViewModel()
    private(set) var birthdaysViewModel = BirthdaysViewModel()
    private(set) var vacanciesViewModel = VacanciesViewModel()
    
    private(set) var searchNewsViewModel = SearchNewsViewModel()

    private let allItemsSubject = PublishSubject<[ListDiffable]>()
    var allItemsObservable: Observable<[ListDiffable]> { return allItemsSubject.asObservable() }

    private(set) var allItems = [ListDiffable]()

    var minimized = true

    // MARK: - Methods

    public func loadAllData() {
    }

    // MARK: - ListDiffable

    func diffIdentifier() -> NSObjectProtocol {
        return self
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let object = object as? StuffViewModel {
            return self == object
        }
        return false
    }

}
