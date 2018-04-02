//
//  BirthdaysViewController.swift
//  Life
//
//  Created by Shyngys Kassymov on 15.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Kingfisher
import Material
import Moya
import RxSwift
import RxCocoa
import SnapKit

class BirthdaysViewController: UIViewController {

    var onUnathorizedError: (() -> Void)?
    var wantCongratulate: ((Employee) -> Void)?

    weak var viewModel: BirthdaysViewModel?
    var didSelectBirthdate: ((Employee) -> Void)?

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
                    placeholderImage: #imageLiteral(resourceName: "ic-user")
                )

                cell.accessoryButton.backgroundColor = .clear
                cell.accessoryButton.setImage(#imageLiteral(resourceName: "ic-bd-active"), for: .normal)

                cell.accessoryButton.addTarget(self, action: #selector(handleCongratulateButton(_:)), for: .touchUpInside)

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

    init(viewModel: BirthdaysViewModel) {
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

        viewModel?.getBirthdays { [weak self] error in
            guard let `self` = self
                else { return }

            if let moyaError = error as? MoyaError,
                moyaError.response?.statusCode == 401,
                let onUnathorizedError = self.onUnathorizedError {
                onUnathorizedError()
            }
        }
        viewModel?.loadingBirthdays.asDriver().drive(onNext: { [weak self] loading in
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
                guard idx == 1 else { return }
                self?.employeesView.tableView?.setContentOffset(.zero, animated: true)
            }
        }
    }

    // MARK: - Actions

    @objc
    private func handleCongratulateButton(_ button: UIButton) {
        let point = button.convert(CGPoint.zero, to: employeesView.tableView)
        let indexPath = employeesView.tableView?.indexPathForRow(at: point)
        if let indexPath = indexPath {
            let employees = viewModel?.employeesToShow.value ?? []
            if employees.count > indexPath.row {
                let employee = employees[indexPath.row]
                if let wantCongratulate = wantCongratulate {
                    wantCongratulate(employee.employee)
                }
            }
        }
    }

    // MARK: - Bind

    private func bind() {
        guard let tableView = employeesView.tableView,
            let viewModel = viewModel else { return }

        let dataSource = self.dataSource

        let items = viewModel.employeesToShow.concatMap { (items) in
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
                if let didSelectBirthdate = self.didSelectBirthdate {
                    didSelectBirthdate(pair.1.employee)
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
        tabItem.title = NSLocalizedString("birthdays", comment: "").uppercased()
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
