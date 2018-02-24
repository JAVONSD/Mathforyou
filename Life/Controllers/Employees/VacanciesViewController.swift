//
//  VacanciesViewController.swift
//  Life
//
//  Created by Shyngys Kassymov on 15.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material
import Moya
import RxSwift
import RxCocoa
import SnapKit

class VacanciesViewController: UIViewController, ViewModelBased {

    typealias ViewModelType = VacanciesViewModel

    var onUnathorizedError: (() -> Void)?

    var viewModel: VacanciesViewModel!
    var didSelectVacancy: ((String) -> Void)?

    private var employeesView: EmployeesView!

    private let itemsChangeSubject = PublishSubject<[VacancyViewModel]>()

    private let disposeBag = DisposeBag()
    private let dataSource =
        RxTableViewSectionedReloadDataSource<SectionModel<VacanciesViewModel, VacancyViewModel>>(
            configureCell: { (_, tv, indexPath, element) in
                let cellId = App.CellIdentifier.vacancyCellId

                let someCell = tv.dequeueReusableCell(withIdentifier: cellId) as? VacancyCell
                guard let cell = someCell else {
                    return VacancyCell(style: .default, reuseIdentifier: cellId)
                }

                cell.positionLabel.text = element.vacancy.jobPosition
                cell.companyLabel.text = element.vacancy.companyName
                cell.salaryLabel.text = element.vacancy.salary

                let itemsCount = tv.numberOfRows(inSection: indexPath.section)
                if indexPath.row == itemsCount - 1 {
                    cell.dividerView.isHidden = true
                } else {
                    cell.dividerView.isHidden = false
                }

                return cell
        },
            viewForHeaderInSection: { (_, _, _) in
                let someHeader = HeaderView(frame: .zero)
                let title = NSLocalizedString("vacancies", comment: "")
                someHeader.titleLabel?.font = App.Font.headline
                someHeader.titleLabel?.text = title
                someHeader.set(insets: .init(
                    top: 0,
                    left: App.Layout.sideOffset,
                    bottom: App.Layout.itemSpacingSmall,
                    right: App.Layout.sideOffset))
                return someHeader
        }
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        bind()

        employeesView.startLoading()
        viewModel.getVacancies { [weak self] error in
            guard let `self` = self
                else { return }

            self.employeesView.stopLoading()

            if let moyaError = error as? MoyaError,
                moyaError.response?.statusCode == 401,
                let onUnathorizedError = self.onUnathorizedError {
                onUnathorizedError()
            } else {
                self.itemsChangeSubject.onNext(self.viewModel.vacancies)
            }
        }
    }

    // MARK: - Bind

    private func bind() {
        guard let tableView = employeesView.tableView else { return }

        let dataSource = self.dataSource

        let observable = itemsChangeSubject.asObservable()
        let items = observable.concatMap { (items) in
            return Observable.just([SectionModel(model: self.viewModel!, items: items)])
        }

        items
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        tableView.rx
            .itemSelected
            .map { indexPath in
                return (indexPath, dataSource[indexPath])
            }
            .subscribe(onNext: { pair in
                if let didSelectVacancy = self.didSelectVacancy {
                    didSelectVacancy(pair.1.vacancy.id)
                }
            })
            .disposed(by: disposeBag)

        tableView.rx
            .setDelegate(employeesView)
            .disposed(by: disposeBag)

        employeesView.configureViewForHeader = { (tableView, section) in
            return dataSource.tableView(tableView, viewForHeaderInSection: section)
        }

        itemsChangeSubject.onNext(viewModel.vacancies)
    }

    // MARK: - UI

    private func setupUI() {
        view.backgroundColor = App.Color.whiteSmoke

        setupTabItem()
        setupEmployeesView()
    }

    private func setupTabItem() {
        tabItem.title = NSLocalizedString("vacancies", comment: "").uppercased()
        tabItem.titleLabel?.font = App.Font.buttonSmall
    }

    private func setupEmployeesView() {
        employeesView = EmployeesView(frame: .zero)
        employeesView.searchView?.didType = { [weak self] text in
            guard let `self` = self else { return }

            if !text.isEmpty {
                self.viewModel.filter(with: text)
                self.itemsChangeSubject.onNext(self.viewModel.filteredVacancies)
            } else {
                self.itemsChangeSubject.onNext(self.viewModel.vacancies)
            }
        }
        view.addSubview(employeesView)
        employeesView.snp.makeConstraints({ [weak self] (make) in
            guard let `self` = self else { return }
            make.edges.equalTo(self.view)
        })
    }

}
