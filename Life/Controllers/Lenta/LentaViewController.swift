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
import NVActivityIndicatorView
import SnapKit

class LentaViewController: ASViewController<ASDisplayNode> {

    private var listAdapter: ListAdapter!
    private(set) var collectionNode: ASCollectionNode!
//    private(set) lazy var spinner = NVActivityIndicatorView(
//        frame: .init(x: 0, y: 0, width: 44, height: 44),
//        type: .circleStrokeSpin,
//        color: App.Color.azure,
//        padding: 0)
    private(set) lazy var spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    private lazy var refreshCtrl = UIRefreshControl()

    private var addButton: FABButton!

    var viewModel: LentaViewModel!

    var onUnathorizedError: (() -> Void)?

    var didTapNews: ((String) -> Void)?
    var didTapSuggestion: ((String) -> Void)?
    var didTapAddNews: (() -> Void)?

    init() {
        let node = ASDisplayNode()
        super.init(node: node)

        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero
        collectionNode = ASCollectionNode(collectionViewLayout: layout)
        collectionNode.contentInset = .init(
            top: 0,
            left: 0,
            bottom: App.Layout.itemSpacingBig,
            right: 0
        )
        node.addSubnode(collectionNode)

        let addNode = ASDisplayNode { () -> UIView in
            self.addButton = FABButton(image: Icon.cm.add, tintColor: .white)
            self.addButton.addTarget(self, action: #selector(self.handleAddButton), for: .touchUpInside)
            self.addButton.backgroundColor = App.Color.azure
            self.addButton.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 56, height: 56))
            }
            return self.addButton
        }
        addNode.style.preferredSize = CGSize(width: 56, height: 56)
        node.addSubnode(addNode)

        node.layoutSpecBlock = { (_, _) in
            let insetSpec = ASInsetLayoutSpec(insets: .init(
                top: 0,
                left: 0,
                bottom: 30,
                right: App.Layout.sideOffset), child: addNode)
            let relativeSpec = ASRelativeLayoutSpec(
                horizontalPosition: .end,
                verticalPosition: .end,
                sizingOption: [],
                child: insetSpec
            )
            return ASOverlayLayoutSpec(child: self.collectionNode, overlay: relativeSpec)
        }

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
        refreshCtrl.tintColor = App.Color.azure
        collectionNode.view.addSubview(refreshCtrl)
    }

    // MARK: - Actions

    @objc
    private func handleAddButton() {
        if let didTapAddNews = didTapAddNews {
            didTapAddNews()
        }
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
        section.didTapNews = didTapNews
        section.didTapSuggestion = didTapSuggestion
        section.onUnathorizedError = { [weak self] in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                User.current.logout()
                if let onUnathorizedError = self.onUnathorizedError {
                    onUnathorizedError()
                }
            }
        }
        section.didFinishLoad = {
            self.spinner.isHidden = true
        }
        return section
    }

    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        spinner.startAnimating()
        return spinner
    }
}
