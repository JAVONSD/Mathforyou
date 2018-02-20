//
//  BirthdaysViewController.swift
//  Life
//
//  Created by Shyngys Kassymov on 15.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa
import SnapKit

class BirthdaysViewController: UIViewController, ViewModelBased, Stepper {

    typealias ViewModelType = BirthdaysViewModel

    var viewModel: BirthdaysViewModel!

    private var employeesView: EmployeesView!

    private let disposeBag = DisposeBag()
    private let dataSource =
        RxTableViewSectionedReloadDataSource<SectionModel<BirthdaysViewModel, EmployeeViewModel>>(
            configureCell: { (_, tv, indexPath, element) in
                let cellId = App.CellIdentifier.employeeCellId

                let someCell = tv.dequeueReusableCell(withIdentifier: cellId) as? EmployeeCell
                guard let cell = someCell else {
                    return EmployeeCell(style: .default, reuseIdentifier: cellId)
                }

                cell.set(imageURL: "")
                cell.set(title: element.employee.fullname)
                cell.set(subtitle: element.employee.jobPosition)

                let itemsCount = tv.numberOfRows(inSection: indexPath.section)
                if indexPath.row == itemsCount - 1 {
                    cell.view?.dividerView?.isHidden = true
                } else {
                    cell.view?.dividerView?.isHidden = false
                }

                return cell
        },
            viewForHeaderInSection: { (tv, _, _) in
                let headerId = App.CellIdentifier.employeeHeaderViewId
                let someHeader = tv.dequeueReusableHeaderFooterView(withIdentifier: headerId) as? HeaderView
                guard let header = someHeader else {
                    return HeaderView(reuseIdentifier: headerId)
                }
                let title = NSLocalizedString("employees", comment: "")
                someHeader?.titleLabel?.font = App.Font.headline
                someHeader?.titleLabel?.text = title
                someHeader?.set(insets: .init(
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

        // For debug
        viewModel = BirthdaysViewModel.sample()

        bind()
    }

    // MARK: - Bind

    private func bind() {
        guard let tableView = employeesView.tableView else { return }

        let dataSource = self.dataSource

        let sectionModels = [SectionModel(model: viewModel!, items: viewModel.employees)]
        let items = Observable.just(sectionModels)

        items
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        tableView.rx
            .itemSelected
            .map { indexPath in
                return (indexPath, dataSource[indexPath])
            }
            .subscribe(onNext: { pair in
                print("Tapped `\(pair.1)` @ \(pair.0)")
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
        tabItem.title = NSLocalizedString("birthdays", comment: "").uppercased()
        tabItem.titleLabel?.font = App.Font.buttonSmall
    }

    private func setupEmployeesView() {
        employeesView = EmployeesView(frame: .zero)
        view.addSubview(employeesView)
        employeesView.snp.makeConstraints({ [weak self] (make) in
            guard let `self` = self else { return }
            make.edges.equalTo(self.view)
        })
    }

}
