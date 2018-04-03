//
//  EmployeesViewController.swift
//  Life
//
//  Created by Shyngys Kassymov on 14.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Kingfisher
import Material
import Moya
import RxSwift
import RxCocoa
import SnapKit

class EmployeesViewController: UIViewController {

    var onUnathorizedError: (() -> Void)?

    weak var viewModel: EmployeesViewModel?
    var didSelectEmployee: ((Employee) -> Void)?

    private var employeesView: EmployeesView!

    private let disposeBag = DisposeBag()
    private let dataSource =
        RxTableViewSectionedReloadDataSource<SectionModel<EmployeesViewModel, EmployeeViewModel>>(
            configureCell: { (_, tv, indexPath, element) in
                let cellId = App.CellIdentifier.employeeCellId

                let someCell = tv.dequeueReusableCell(withIdentifier: cellId) as? EmployeeCell
                guard let cell = someCell else {
                    return EmployeeCell(style: .default, reuseIdentifier: cellId)
                }

                cell.titleLabel.text = element.employee.fullname

                var subtitleText = element.employee.jobPosition
                let mobilePhoneNumber = element.employee.workPhoneNumber
                if !mobilePhoneNumber.isEmpty {
                    subtitleText += "\n\(mobilePhoneNumber)"
                }
                cell.subtitleLabel.text = subtitleText

                cell.employeeImageView.backgroundColor = .clear
                cell.employeeImageView.set(
                    image: "",
                    employeeCode: element.employee.code,
                    placeholderImage: #imageLiteral(resourceName: "ic-user"),
                    size: CGSize(width: 40, height: 40)
                )

                cell.accessoryButton.isHidden = true

                let itemsCount = tv.numberOfRows(inSection: indexPath.section)
                if indexPath.row == itemsCount - 1 {
                    cell.separatorView.isHidden = true
                } else {
                    cell.separatorView.isHidden = false
                }

                return cell
        },
            viewForHeaderInSection: { (_, _, _) in
                let someHeader = HeaderView(frame: .zero)
                let title = NSLocalizedString("employees", comment: "")
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

    init(viewModel: EmployeesViewModel) {
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

        viewModel?.getEmployees()
        viewModel?.onError.observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] error in
            guard let `self` = self
                else { return }

            if let moyaError = error as? MoyaError,
                moyaError.response?.statusCode == 401,
                let onUnathorizedError = self.onUnathorizedError {
                onUnathorizedError()
            }
        }).disposed(by: disposeBag)
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
                guard idx == 0 else { return }
                self?.employeesView.tableView?.setContentOffset(.zero, animated: true)
            }
        }
    }

    // MARK: - Bind

    private func bind() {
        guard let tableView = employeesView.tableView,
            let viewModel = viewModel else { return }

        let dataSource = self.dataSource

        let observable = viewModel.filteredEmployees.asObservable()
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
                if let didSelectEmployee = self.didSelectEmployee {
                    didSelectEmployee(pair.1.employee)
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
        tabItem.title = NSLocalizedString("all", comment: "").uppercased()
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
