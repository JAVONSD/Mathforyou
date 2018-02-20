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
import SnapKit

class BIOfficeViewController: ASViewController<ASCollectionNode> {

    private var listAdapter: ListAdapter!
    private var collectionNode: ASCollectionNode {
        return node
    }
    private lazy var refreshCtrl = UIRefreshControl()

    var viewModel: BIOfficeViewModel!

    var onUnathorizedError: (() -> Void)?

    init() {
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

        viewModel = BIOfficeViewModel()

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
        collectionNode.view.addSubview(refreshCtrl)
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

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if let viewModel = object as? EventsViewModel {
            let section = EventsSectionController(viewModel: viewModel)
            section.onUnathorizedError = { [weak self] in
                guard let `self` = self else { return }
                self.onUnauthorized()
            }
            return section
        } else if let viewModel = object as? TasksAndRequestsViewModel {
            let section = TasksAndRequestsSectionController(viewModel: viewModel)
            section.onUnathorizedError = { [weak self] in
                guard let `self` = self else { return }
                self.onUnauthorized()
            }
            return section
        } else if let viewModel = object as? KPIViewModel {
            let section = KPISectionController(viewModel: viewModel)
            section.onUnathorizedError = { [weak self] in
                guard let `self` = self else { return }
                self.onUnauthorized()
            }
            return section
        } else if let viewModel = object as? SBViewModel {
            let section = SBSectionController(viewModel: viewModel)
            section.onUnathorizedError = { [weak self] in
                guard let `self` = self else { return }
                self.onUnauthorized()
            }
            return section
        } else if let viewModel = object as? IDPViewModel {
            let section = IDPSectionController(viewModel: viewModel)
            section.onUnathorizedError = { [weak self] in
                guard let `self` = self else { return }
                self.onUnauthorized()
            }
            return section
        }

        return ListSectionController()
    }

    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}
