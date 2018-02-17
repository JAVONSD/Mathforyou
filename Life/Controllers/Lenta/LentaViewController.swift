//
//  LentaViewController.swift
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

class LentaViewController: ASViewController<ASCollectionNode> {

    private var listAdapter: ListAdapter!
    private var collectionNode: ASCollectionNode {
        return node
    }
    private lazy var spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    private lazy var refreshCtrl = UIRefreshControl()

    var viewModel: LentaViewModel!

    var onUnathorizedError: (() -> Void)?

    init() {
        let layout = UICollectionViewFlowLayout()
        let node = ASCollectionNode(collectionViewLayout: layout)

        super.init(node: node)

        viewModel = LentaViewModel()

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
            top: 176,
            left: 0,
            bottom: 0,
            right: 0)

        refreshCtrl = UIRefreshControl()
        refreshCtrl.addTarget(self, action: #selector(refreshFeed), for: .valueChanged)
        collectionNode.view.addSubview(refreshCtrl)
    }

    // MARK: - Methods

    @objc
    private func refreshFeed() {
        guard let secCtrl = listAdapter
            .sectionController(for: viewModel) as? RefreshingSectionControllerType else {
            return
        }

        secCtrl.refreshContent {
            self.refreshCtrl.endRefreshing()
        }
    }

}

extension LentaViewController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return [viewModel]
    }

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        let section = NewsSectionController(viewModel: viewModel)
        section.onUnathorizedError = { [weak self] in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                User.current.logout()
                if let onUnathorizedError = self.onUnathorizedError {
                    onUnathorizedError()
                }
            }
        }
        return section
    }

    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        spinner.startAnimating()
        return spinner
    }
}

extension LentaViewController: ASCollectionDelegate {
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        print("Did select collectionNode item at index path - (indexPath)")
    }
}
