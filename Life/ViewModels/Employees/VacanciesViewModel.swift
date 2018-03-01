//
//  VacanciesViewModel.swift
//  Life
//
//  Created by Shyngys Kassymov on 15.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import Moya
import RxSwift

class VacanciesViewModel: NSObject, ViewModel {
    private(set) var vacancies = [VacancyViewModel]()
    private(set) var filteredVacancies = [VacancyViewModel]()

    private(set) var loading = false
    private(set) var didLoadVacancies = false

    private let disposeBag = DisposeBag()
    let itemsChangeSubject = PublishSubject<[VacancyViewModel]>()

    private let provider = MoyaProvider<EmployeesService>(
        plugins: [
            AuthPlugin(tokenClosure: {
                return User.current.token
            })
        ]
    )

    convenience init(vacancies: [VacancyViewModel]) {
        self.init()
        self.vacancies = vacancies
    }

    // MARK: - Methods

    public func getVacancies(completion: @escaping ((Error?) -> Void)) {
        if loading || didLoadVacancies {
            completion(nil)
            if !loading {
                self.itemsChangeSubject.onNext(self.vacancies)
            }
            return
        }
        loading = true

        provider
            .rx
            .request(.vacancies)
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                self.loading = false

                switch response {
                case .success(let json):
                    if let lentaItems = try? JSONDecoder().decode([Vacancy].self, from: json.data) {
                        let items = lentaItems.map { VacancyViewModel(vacancy: $0) }
                        self.vacancies = items
                        self.filteredVacancies = items
                        self.didLoadVacancies = true

                        completion(nil)
                    } else {
                        completion(nil)
                    }
                    self.itemsChangeSubject.onNext(self.vacancies)
                case .error(let error):
                    completion(error)
                    self.itemsChangeSubject.onNext(self.vacancies)
                }
            }
            .disposed(by: disposeBag)
    }

    public func filter(with text: String) {
        if text.isEmpty {
            itemsChangeSubject.onNext(vacancies)
            return
        }

        DispatchQueue.global().async {
            let text = text.lowercased()

            self.filteredVacancies = self.vacancies.filter({ (vacancyViewModel) -> Bool in
                var include = false
                include = include
                    || vacancyViewModel.vacancy.jobPosition.lowercased().contains(text)
                if !include {
                    include = include
                        || vacancyViewModel.vacancy.companyName.lowercased().contains(text)
                }
                if !include {
                    include = include
                        || vacancyViewModel.vacancy.departmentName.lowercased().contains(text)
                }
                if !include {
                    include = include
                        || vacancyViewModel.vacancy.salary.lowercased().contains(text)
                }

                return include
            })

            DispatchQueue.main.async {
                self.itemsChangeSubject.onNext(self.filteredVacancies)
            }
        }
    }
}

extension VacanciesViewModel: Mockable {
    typealias T = VacanciesViewModel

    static func sample() -> VacanciesViewModel {
        var vacancies = [VacancyViewModel]()
        for _ in 0..<5 {
            let json = [
                "id": UUID().uuidString,
                "jobPosition": "Начальник Коммерческого Отдела Дивизиона",
                "companyName": "Otau Development Group ТОО",
                "createDate": "2018-01-30T00:00:00",
                "departmentName": "Коммерческий отдел",
                "salary": "Не указана"
            ]
            if let vacancy = try? JSONDecoder().decode(Vacancy.self, from: json.toJSONData()) {
                let vacancyViewModel = VacancyViewModel(vacancy: vacancy)
                vacancies.append(vacancyViewModel)
            }
        }
        return VacanciesViewModel(vacancies: vacancies)
    }
}

struct VacancyViewModel: ViewModel {
    var vacancy: Vacancy
}
