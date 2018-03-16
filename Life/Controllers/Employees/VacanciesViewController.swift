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

class VacanciesViewController: UIViewController {

    var onUnathorizedError: (() -> Void)?

    weak var viewModel: VacanciesViewModel?
    var didSelectVacancy: ((String) -> Void)?

    private var employeesView: EmployeesView!

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
//                cell.salaryLabel.text = element.vacancy.salary

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

    init(viewModel: VacanciesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        bind()

        viewModel?.getVacancies { [weak self] error in
            guard let `self` = self
                else { return }

            if let moyaError = error as? MoyaError,
                moyaError.response?.statusCode == 401,
                let onUnathorizedError = self.onUnathorizedError {
                onUnathorizedError()
            }
        }
        viewModel?.loading.asDriver().drive(onNext: { [weak self] loading in
            if loading {
                self?.employeesView.startLoading()
            } else {
                self?.employeesView.stopLoading()
            }
        }).disposed(by: disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let tabVC = parent as? StuffViewController {
            tabVC.needScrollToTop = { [weak self] idx in
                guard idx == 2 else { return }
                self?.employeesView.tableView?.setContentOffset(.zero, animated: true)
            }
        }
    }

    // MARK: - Bind

    private func bind() {
        guard let tableView = employeesView.tableView,
            let viewModel = viewModel else { return }

        let dataSource = self.dataSource

        let observable = viewModel.itemsChangeSubject.asObservable()
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
            self.viewModel?.filter(with: text)
        }
        view.addSubview(employeesView)
        employeesView.snp.makeConstraints({ [weak self] (make) in
            guard let `self` = self else { return }
            make.edges.equalTo(self.view)
        })
    }

}
