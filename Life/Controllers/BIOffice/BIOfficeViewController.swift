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

class BIOfficeViewController: ASViewController<ASCollectionNode> {

    private var listAdapter: ListAdapter!
    private var collectionNode: ASCollectionNode {
        return node
    }
    private lazy var refreshCtrl = UIRefreshControl()

    private(set) var viewModel: BIOfficeViewModel
    private let disposeBag = DisposeBag()

    var onUnathorizedError: (() -> Void)?
    var didTapAddRequest: (() -> Void)?

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

        setupBindings()
        getData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        viewModel.syncUserProfile {
            if let onUnathorizedError = self.onUnathorizedError {
                onUnathorizedError()
            }
        }
    }

    // MARK: - Methods

    private func getData() {
        viewModel.eventsViewModel.getMine { error in
            if let moyaError = error as? MoyaError,
                moyaError.response?.statusCode == 401,
                let onUnathorizedError = self.onUnathorizedError {
                onUnathorizedError()
            }
        }
        viewModel.tasksAndRequestsViewModel.getAllTasksAndRequests()
    }

    private func setupBindings() {
        viewModel.eventsViewModel.eventsObservable.subscribe(onNext: { [weak self] items in
            print("Number of items - \(items.count)")
            self?.collectionNode.reloadSections(IndexSet(integer: 0))
        }).disposed(by: disposeBag)
    }

    @objc
    private func refreshFeed() {
        guard let secCtrl = listAdapter
            .sectionController(for: viewModel.eventsViewModel) as? RefreshingSectionControllerType else {
                return
        }

        secCtrl.refreshContent {
            self.refreshCtrl.endRefreshing()
        }
    }

    private func onUnauthorized() {
        DispatchQueue.main.async {
            User.current.logout()
            if let onUnathorizedError = self.onUnathorizedError {
                onUnathorizedError()
            }
        }
    }

}

extension BIOfficeViewController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return [
            viewModel.eventsViewModel,
            viewModel.tasksAndRequestsViewModel,
            viewModel.kpiViewModel,
            viewModel.sbvViewModel,
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
            if let `self` = self,
                let navigationController = self.navigationController as? AppToolbarController {
                navigationController.step.accept(AppStep.tasksAndRequests)
            }
        }
        section.didTapAddRequest = didTapAddRequest
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

    private func sbSection(_ viewModel: SBViewModel) -> ListSectionController {
        let section = SBSectionController(viewModel: viewModel)
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
        case let viewModel as SBViewModel:
            return sbSection(viewModel)
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
