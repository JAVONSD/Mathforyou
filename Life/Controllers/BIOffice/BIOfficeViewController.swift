//
//  BIOfficeViewController.swift
//  Life
//
//  Created by Shyngys Kassymov on 14.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import IGListKit
import Material
import Moya
import RxSwift
import SnapKit

class BIOfficeViewController: ASViewController<ASCollectionNode>, Stepper {

    private var listAdapter: ListAdapter!
    private var collectionNode: ASCollectionNode {
        return node
    }
    private lazy var refreshCtrl = UIRefreshControl()

    private(set) var viewModel: BIOfficeViewModel
    private let disposeBag = DisposeBag()

    init(viewModel: BIOfficeViewModel) {
        self.viewModel = viewModel

        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero
        let node = ASCollectionNode(collectionViewLayout: layout)
        node.contentInset = .init(
            top: 0,
            left: 0,
            bottom: App.Layout.itemSpacingBig,
            right: 0
        )

        super.init(node: node)

        let updater = ListAdapterUpdater()
        listAdapter = ListAdapter(updater: updater, viewController: self, workingRangeSize: 0)
        listAdapter.dataSource = self
        listAdapter.setASDKCollectionNode(collectionNode)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionNode.view.backgroundColor = App.Color.whiteSmoke
        collectionNode.view.alwaysBounceVertical = true
        collectionNode.view.scrollIndicatorInsets = .init(
            top: 232,
            left: 0,
            bottom: 0,
            right: 0)

        refreshCtrl = UIRefreshControl()
        refreshCtrl.addTarget(self, action: #selector(refreshFeed), for: .valueChanged)
        refreshCtrl.tintColor = App.Color.azure
        collectionNode.view.addSubview(refreshCtrl)

        refreshFeed()
    }

    // MARK: - Methods

    @objc
    private func refreshFeed() {
        let tasksAndRequestsSC = listAdapter.sectionController(
            for: viewModel.tasksAndRequestsViewModel) as? RefreshingSectionControllerType
        tasksAndRequestsSC?.refreshContent {
            self.refreshCtrl.endRefreshing()
        }
    }

    private func onUnauthorized() {
        DispatchQueue.main.async { [weak self] in
            User.current.logout()
            self?.step.accept(AppStep.unauthorized)
        }
    }

}

extension BIOfficeViewController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return [
            viewModel.eventsViewModel,
            viewModel.tasksAndRequestsViewModel,
            viewModel.kpiViewModel,
            viewModel.hrViewModel,
            viewModel.idpViewModel
        ]
    }

    private func eventsSection(_ viewModel: EventsViewModel) -> ListSectionController {
        let section = EventsSectionController(viewModel: viewModel)
        section.onUnathorizedError = { [weak self] in
            guard let `self` = self else { return }
            self.onUnauthorized()
        }
        return section
    }

    private func tasksAndRequestsSection(
        _ viewModel: TasksAndRequestsViewModel) -> ListSectionController {
        let section = TasksAndRequestsSectionController(viewModel: viewModel)
        section.onUnathorizedError = { [weak self] in
            guard let `self` = self else { return }
            self.onUnauthorized()
        }
        section.didTapOnTaskOrRequest = { index in
            print("Openning task or request ...")
        }
        section.didTapOnTasksAndRequests = { [weak self] in
            self?.step.accept(AppStep.tasksAndRequests)
        }
        section.didTapAddRequest = { [weak self] in
            let alert = UIAlertController(
                title: NSLocalizedString("choose_option", comment: ""),
                message: nil,
                preferredStyle: .actionSheet)
            alert.popoverPresentationController?.sourceView = self?.view

            let taskAction = UIAlertAction(
                title: NSLocalizedString("new_task", comment: ""),
                style: .default, handler: { [weak self] _ in
                    self?.step.accept(
                        AppStep.createTask(didCreateTask: { [weak self] in
                            self?.refreshFeed()
                        })
                    )
                }
            )
            alert.addAction(taskAction)

            let requestAction = UIAlertAction(
                title: NSLocalizedString("new_request", comment: ""),
                style: .default, handler: { [weak self] _ in
                    self?.step.accept(
                        AppStep.createRequest(category: .it, didCreateRequest: { [weak self] in
                            self?.refreshFeed()
                        })
                    )
                }
            )
            alert.addAction(requestAction)

            let cancelAction = UIAlertAction(
                title: NSLocalizedString("cancel", comment: ""),
                style: .cancel,
                handler: nil)
            alert.addAction(cancelAction)

            self?.present(alert, animated: true, completion: nil)
        }
        return section
    }

    private func kpiSection(_ viewModel: KPIViewModel) -> ListSectionController {
        let section = KPISectionController(viewModel: viewModel)
        section.onUnathorizedError = { [weak self] in
            guard let `self` = self else { return }
            self.onUnauthorized()
        }
        return section
    }

    private func hrSection(_ viewModel: HRViewModel) -> ListSectionController {
        let section = HRSectionController(viewModel: viewModel)
        section.onUnathorizedError = { [weak self] in
            guard let `self` = self else { return }
            self.onUnauthorized()
        }
        return section
    }

    private func idpSection(_ viewModel: IDPViewModel) -> ListSectionController {
        let section = IDPSectionController(viewModel: viewModel)
        section.onUnathorizedError = { [weak self] in
            guard let `self` = self else { return }
            self.onUnauthorized()
        }
        return section
    }

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        switch object {
        case let viewModel as EventsViewModel:
            return eventsSection(viewModel)
        case let viewModel as TasksAndRequestsViewModel:
            return tasksAndRequestsSection(viewModel)
        case let viewModel as KPIViewModel:
            return kpiSection(viewModel)
        case let viewModel as HRViewModel:
            return hrSection(viewModel)
        case let viewModel as IDPViewModel:
            return idpSection(viewModel)
        default:
            break
        }

        return ListSectionController()
    }

    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}
