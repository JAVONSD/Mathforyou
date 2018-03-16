//
//  TasksAndRequestsViewController.swift
//  Life
//
//  Created by Shyngys Kassymov on 21.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import IGListKit
import Material
import RxSwift
import RxCocoa
import SnapKit

class TasksAndRequestsViewController: UIViewController, Stepper {

    private(set) weak var viewModel: TasksAndRequestsViewModel?
    private var lastSelectedTabIndex = 0

    private var tasksAndRequestsView: TasksAndRequetsView!

    private let itemsChangeSubject = PublishSubject<[ListDiffable]>()

    private let disposeBag = DisposeBag()
    private let dataSource =
        RxTableViewSectionedReloadDataSource<SectionModel<TasksAndRequestsViewModel, ListDiffable>>(
            configureCell: { (_, tv, _, element) in
                let cellId = App.CellIdentifier.taskOrReqeustCellId

                let someCell = tv.dequeueReusableCell(withIdentifier: cellId) as? TRTableViewCell
                guard let cell = someCell else {
                    return TRTableViewCell(style: .default, reuseIdentifier: cellId)
                }

                if let viewModel = element as? TaskViewModel {
                    cell.titleLabel.text = viewModel.task.topic

                    var detailText = viewModel.task.statusCode.name
                    if let date = viewModel.task.startDate {
                        let fmtDate = date.prettyDateString()
                        detailText += "\n\(fmtDate)"
                    }
                    cell.subtitleLabel.text = detailText
                } else if let viewModel = element as? RequestViewModel {
                    cell.titleLabel.text = viewModel.request.topic

                    var detailText = viewModel.request.statusCode.name
                    let date = viewModel.request.registrationDate
                    let fmtDate = date.prettyDateString()
                    detailText += "\n\(fmtDate)"
                    cell.subtitleLabel.text = detailText
                }

                return cell
        }
    )

    init(viewModel: TasksAndRequestsViewModel) {
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
    }

    // MARK: - Bind

    private func bind() {
        guard let tableView = tasksAndRequestsView.tableView,
            let viewModel = viewModel else { return }

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
            .setDelegate(tasksAndRequestsView)
            .disposed(by: disposeBag)

        itemsChangeSubject.onNext(viewModel.currentItems)
    }

    // MARK: - UI

    private func setupUI() {
        view.backgroundColor = .white

        setupTaskAndRequestsView()
    }

    private func setupTaskAndRequestsView() {
        tasksAndRequestsView = TasksAndRequetsView(frame: .zero)
        tasksAndRequestsView.didTapCloseButton = { [weak self] in
            self?.viewModel?.step.accept(AppStep.tasksAndRequestsDone)
        }
        tasksAndRequestsView.didTapTabItem = { [weak self] index in
            if let last = self?.lastSelectedTabIndex,
                index == last {
                self?.tasksAndRequestsView.tableView?.setContentOffset(.zero, animated: true)
            } else {
                self?.viewModel?.selectedItemsType = index == 0 ? .inbox : .outbox
                self?.itemsChangeSubject.onNext(self?.viewModel?.currentItems ?? [])
            }
            self?.lastSelectedTabIndex = index

        }
        view.addSubview(tasksAndRequestsView)
        tasksAndRequestsView.snp.makeConstraints({ [weak self] (make) in
            guard let `self` = self else { return }
            make.top.equalTo(self.topLayoutGuide.snp.bottom)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
        })

        tasksAndRequestsView.setNeedsLayout()
        tasksAndRequestsView.layoutIfNeeded()

        if let tabBar = tasksAndRequestsView.tabBar {
            let currentIndex = viewModel?.selectedItemsType == .inbox ? 0 : 1
            lastSelectedTabIndex = currentIndex
            tabBar.select(at: currentIndex, completion: nil)
        }
    }

}
