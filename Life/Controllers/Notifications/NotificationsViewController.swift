//
//  NotificationsViewController.swift
//  Life
//
//  Created by Shyngys Kassymov on 17.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa
import SnapKit

class NotificationsViewController: UIViewController, ViewModelBased, Stepper {

    typealias ViewModelType = NotificationsViewModel

    var viewModel: NotificationsViewModel!

    private var notificationsView: NotificationView!

    private let disposeBag = DisposeBag()
    private let dataSource =
        RxTableViewSectionedReloadDataSource<SectionModel<NotificationsViewModel, NotificationViewModel>>(
            configureCell: { (_, tv, indexPath, element) in
                let cellId = App.CellIdentifier.notificationsCellId

                let someCell = tv.dequeueReusableCell(withIdentifier: cellId) as? NotificationCell
                guard let cell = someCell else {
                    return NotificationCell(style: .default, reuseIdentifier: cellId)
                }

                cell.set(title: element.title)
                cell.set(subtitle: element.date)

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
        viewModel = NotificationsViewModel.sample()

        bind()
    }

    // MARK: - Bind

    private func bind() {
        guard let tableView = notificationsView.tableView else { return }

        let dataSource = self.dataSource

        let sectionModels = [SectionModel(model: viewModel!, items: viewModel.notifications)]
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
            .setDelegate(notificationsView)
            .disposed(by: disposeBag)
    }

    // MARK: - UI

    private func setupUI() {
        view.backgroundColor = .white

        setupEmployeesView()
    }

    private func setupEmployeesView() {
        notificationsView = NotificationView(frame: .zero)
        notificationsView.didTapCloseButton = { [weak self] in
            self?.step.accept(AppStep.notificationsDone)
        }
        view.addSubview(notificationsView)
        notificationsView.snp.makeConstraints({ [weak self] (make) in
            guard let `self` = self else { return }
            make.top.equalTo(self.topLayoutGuide.snp.bottom)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
        })
    }

}
