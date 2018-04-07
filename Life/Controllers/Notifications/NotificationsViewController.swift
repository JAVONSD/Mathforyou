//
//  NotificationsViewController.swift
//  Life
//
//  Created by Shyngys Kassymov on 17.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
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

        viewModel.getNotifications()
    }

    // MARK: - Bind

    private func bind() {
        guard let tableView = notificationsView.tableView else { return }

        let dataSource = self.dataSource

        let observable = viewModel.notifications.asObservable()
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
            .subscribe(onNext: { [weak self] pair in
                self?.viewModel.readNotification(pair.1.notification.id)
            })
            .disposed(by: disposeBag)

        tableView.rx
            .setDelegate(notificationsView)
            .disposed(by: disposeBag)

        viewModel.loading.observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] isLoading in
                isLoading
                    ? self?.notificationsView.startLoading()
                    : self?.notificationsView.stopLoading()
            })
            .disposed(by: disposeBag)

        viewModel.onError.observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                if let moyaError = error as? MoyaError,
                    moyaError.response?.statusCode == 401,
                    let onUnathorizedError = self?.onUnathorizedError {
                    onUnathorizedError()
                }
            })
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
        notificationsView.tableView?.emptyDataSetSource = self
        notificationsView.tableView?.emptyDataSetDelegate = self
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

extension NotificationsViewController: DZNEmptyDataSetSource {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = NSLocalizedString("no_new_notifications", comment: "")
        let attText = NSMutableAttributedString(string: text)

        let allRange = NSRange(location: 0, length: attText.length)
        attText.addAttribute(.font, value: App.Font.subhead, range: allRange)
        attText.addAttribute(.foregroundColor, value: App.Color.black, range: allRange)

        return attText
    }
}

extension NotificationsViewController: DZNEmptyDataSetDelegate {
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return !viewModel.loading.value
    }
}
