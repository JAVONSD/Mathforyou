//
//  MenuViewController.swift
//  Life
//
//  Created by Shyngys Kassymov on 14.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa
import SnapKit

class MenuViewController: UIViewController, ViewModelBased, Stepper {

    typealias ViewModelType = MenuViewModel

    var viewModel: MenuViewModel!

    var onUnathorizedError: (() -> Void)?

    var topQuestionTapped: (() -> Void)?

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

                cell.set(imageURL: element.image)
                cell.set(title: element.title)
                cell.set(subtitle: element.subtitle)

                cell.view?.imageView?.backgroundColor = App.Color.paleGreyTwo
                cell.set(imageSize: CGSize(width: 24, height: 24))
                cell.set(imageRadius: App.Layout.cornerRadiusSmall)
                cell.setDivider(leftInset: 70)

                cell.detailView.label.isHidden = true

                let itemsCount = tv.numberOfRows(inSection: indexPath.section)
                if indexPath.row == itemsCount - 1 {
                    cell.view?.dividerView?.isHidden = true
                } else {
                    cell.view?.dividerView?.isHidden = false
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
            .subscribe(onNext: { pair in
                if pair.0.row == 3 {
                    if let topQuestionTapped = self.topQuestionTapped {
                        topQuestionTapped()
                    }
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
    }

}
