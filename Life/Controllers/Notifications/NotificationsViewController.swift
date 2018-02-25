//
//  NotificationsViewController.swift
//  Life
//
//  Created by Shyngys Kassymov on 17.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material
import Moya
import RxSwift
import RxCocoa
import SnapKit

class NotificationsViewController: UIViewController, ViewModelBased, Stepper {

    typealias ViewModelType = NotificationsViewModel

    var onUnathorizedError: (() -> Void)?

    var viewModel: NotificationsViewModel!

    private var notificationsView: NotificationView!

    private let itemsChangeSubject = PublishSubject<[NotificationViewModel]>()

    private let disposeBag = DisposeBag()
    private let dataSource =
        RxTableViewSectionedReloadDataSource<SectionModel<NotificationsViewModel, NotificationViewModel>>(
            configureCell: { (_, tv, indexPath, element) in
                let cellId = App.CellIdentifier.notificationsCellId

                let someCell = tv.dequeueReusableCell(withIdentifier: cellId) as? NotificationCell
                guard let cell = someCell else {
                    return NotificationCell(style: .default, reuseIdentifier: cellId)
                }

                cell.set(title: element.notification.message)
                cell.set(subtitle: element.notification
                    .createDate.prettyDateOrTimeAgoString(format: "dd.MM.yyyy HH:mm"))

                let itemsCount = tv.numberOfRows(inSection: indexPath.section)
                if indexPath.row == itemsCount - 1 {
                    cell.view?.dividerView?.isHidden = true
                } else {
                    cell.view?.dividerView?.isHidden = false
                }

                return cell
            },
            canEditRowAtIndexPath: { (_, _) in
                return true
            }
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        bind()

        notificationsView.startLoading()
        viewModel.getNotifications { [weak self] error in
            guard let `self` = self
                else { return }

            self.notificationsView.stopLoading()

            if let moyaError = error as? MoyaError,
                moyaError.response?.statusCode == 401,
                let onUnathorizedError = self.onUnathorizedError {
                onUnathorizedError()
            } else {
                self.itemsChangeSubject.onNext(self.viewModel.notifications)
            }
        }
    }

    // MARK: - Bind

    private func bind() {
        guard let tableView = notificationsView.tableView else { return }

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
                print("Tapped `\(pair.1)` @ \(pair.0)")
            })
            .disposed(by: disposeBag)

        tableView.rx
            .itemDeleted
            .map { indexPath in
                return (indexPath, dataSource[indexPath])
            }
            .subscribe(onNext: { pair in
                self.viewModel.readNotification(pair.1.notification.id, completion: { (error) in
                    self.itemsChangeSubject.onNext(self.viewModel.notifications)

                    if let moyaError = error as? MoyaError,
                        moyaError.response?.statusCode == 401,
                        let onUnathorizedError = self.onUnathorizedError {
                        onUnathorizedError()
                    }
                })
            })
            .disposed(by: disposeBag)

        tableView.rx
            .setDelegate(notificationsView)
            .disposed(by: disposeBag)

        itemsChangeSubject.onNext(viewModel.notifications)
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
