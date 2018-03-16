//
//  MenuViewController.swift
//  Life
//
//  Created by Shyngys Kassymov on 14.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Kingfisher
import Material
import RxSwift
import RxCocoa
import SnapKit

class MenuViewController: UIViewController, ViewModelBased, Stepper {

    typealias ViewModelType = MenuViewModel

    var viewModel: MenuViewModel!

    private var menuView: MenuView!

    private let disposeBag = DisposeBag()
    private let dataSource =
        RxTableViewSectionedReloadDataSource<SectionModel<MenuViewModel, MenuItemViewModel>>(
            configureCell: { (_, tv, indexPath, element) in
                let cellId = App.CellIdentifier.menuCellId

                let someCell = tv.dequeueReusableCell(withIdentifier: cellId) as? EmployeeCell
                guard let cell = someCell else {
                    return EmployeeCell(style: .default, reuseIdentifier: cellId)
                }

                cell.titleLabel.text = element.title
                cell.subtitleLabel.text = element.subtitle

                cell.employeeImageView.layer.cornerRadius = App.Layout.cornerRadiusSmall
                cell.employeeImageView.backgroundColor = App.Color.paleGreyTwo
                cell.imageSize = CGSize(width: 24, height: 24)
                cell.employeeImageView.set(image: element.image, employeeCode: nil)

                cell.separatorLeftOffset = 70
                cell.accessoryButton.isHidden = true

                let itemsCount = tv.numberOfRows(inSection: indexPath.section)
                if indexPath.row == itemsCount - 1 {
                    cell.separatorView.isHidden = true
                } else {
                    cell.separatorView.isHidden = false
                }

                return cell
        }
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()

        // For debug
        viewModel = MenuViewModel.sample()

        bind()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let tabVC = parent as? AppTabBarController {
            tabVC.didTapTab = { [weak self] idx in
                guard idx == 4, tabVC.currentTabIndex == idx else { return }
                self?.menuView.tableView?.setContentOffset(.zero, animated: true)
            }
        }
    }

    // MARK: - Bind

    private func bind() {
        guard let tableView = menuView.tableView else { return }

        let dataSource = self.dataSource

        let sectionModels = [SectionModel(model: viewModel!, items: viewModel.items)]
        let items = Observable.just(sectionModels)

        items
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        tableView.rx
            .itemSelected
            .map { indexPath in
                return (indexPath, dataSource[indexPath])
            }
            .subscribe(onNext: { [weak self] pair in
                if pair.0.row == 3 {
                    self?.step.accept(AppStep.topQuestions)
                }
            })
            .disposed(by: disposeBag)

        tableView.rx
            .setDelegate(menuView)
            .disposed(by: disposeBag)
    }

    // MARK: - UI

    private func setupUI() {
        view.backgroundColor = App.Color.whiteSmoke

        setupEmployeesView()
    }

    private func setupEmployeesView() {
        menuView = MenuView(frame: .zero)
        view.addSubview(menuView)
        menuView.snp.makeConstraints({ [weak self] (make) in
            guard let `self` = self else { return }
            make.edges.equalTo(self.view)
        })

        menuView.headerButton.rx.tap.asDriver().throttle(0.5).drive(onNext: { [weak self] in
            self?.step.accept(AppStep.profile)
        }).disposed(by: disposeBag)
    }

}
