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
                cell.employeeImageView.set(
                    image: element.image,
                    employeeCode: nil
                )

                cell.separatorLeftOffset = 70
                cell.accessoryButtonIsHidden = true
                cell.disclosureImageViewIsHidden = false
                cell.separatorView.isHidden = false
                cell.containerInsets = .zero
                cell.textLeftOffset = App.Layout.itemSpacingMedium
                cell.textTopOffset = 19
                cell.titleLabel.textAlignment = .left

                let itemsCount = tv.numberOfRows(inSection: indexPath.section)

                if indexPath.row == itemsCount - 2 {
                    cell.separatorLeftOffset = App.Layout.sideOffset
                    cell.containerInsets = .init(top: 0, left: 0, bottom: 32, right: 0)
                    
                } else if indexPath.row == itemsCount - 1 {
                    cell.disclosureImageViewIsHidden = true
                    cell.separatorView.isHidden = true
                    cell.imageSize = .zero
                    cell.textLeftOffset = 0
                    cell.textTopOffset = App.Layout.itemSpacingMedium
                    cell.titleLabel.textAlignment = .center
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
                guard idx == 3, tabVC.currentTabIndex == idx else { return }
                self?.menuView.tableView?.setContentOffset(.zero, animated: true)
            }
        }
        
        navigationController?.navigationBar.isTranslucent = false
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
                if pair.0.row == 0 {
                    let title = NSLocalizedString("Обучение", comment: "")
                    self?.openEmptyScreen(with: title)
                } else if pair.0.row == 1 {
                    let title = NSLocalizedString("Развитие", comment: "")
                    self?.openEmptyScreen(with: title)
                }
                else if pair.0.row == 2 {
                    let title = NSLocalizedString("Опросник", comment: "")
                    self?.openEmptyScreen(with: title)
                }
                else if pair.0.row == 3 {
                    afterDelayOnMain(0, closure: {
                        let title = NSLocalizedString("Приложения", comment: "")
                        self?.openApps(with: title)
                    })
                }
                else if pair.0.row == 4 {
                    self?.askToConfirmLogout()
                }
            })
            .disposed(by: disposeBag)

        tableView.rx
            .setDelegate(menuView)
            .disposed(by: disposeBag)
    }

    // MARK: - Methods
    
    private func openApps(with title: String) {
        let vc = AppsViewController()
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        vc.collectionView = collectionView
        vc.titleStr = title
        parent?.navigationController?.navigationBar.isTranslucent = true
        parent?.navigationController?.pushViewController(vc, animated: true)
    }

    private func openEmptyScreen(with title: String) {
        let vc = EmptyTableViewController(style: .plain)
        vc.title = title
        parent?.navigationController?.pushViewController(vc, animated: true)
    }

    private func askToConfirmLogout() {
        let alert = UIAlertController(
            title: NSLocalizedString("confirm_action", comment: ""),
            message: NSLocalizedString("are_you_sure", comment: ""),
            preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = view

        let taskAction = UIAlertAction(
            title: NSLocalizedString("log_out", comment: ""),
            style: .destructive, handler: { [weak self] _ in
                self?.logout()
            }
        )
        alert.addAction(taskAction)

        let cancelAction = UIAlertAction(
            title: NSLocalizedString("cancel", comment: ""),
            style: .cancel,
            handler: nil)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    private func logout() {
        User.current.logout()
        step.accept(AppStep.login)
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

        menuView.headerButton.rx.tap.asDriver()
            .throttle(0.5)
            .drive(onNext: { [weak self] in
            self?.step.accept(AppStep.profile)
        }).disposed(by: disposeBag)
    }

}









