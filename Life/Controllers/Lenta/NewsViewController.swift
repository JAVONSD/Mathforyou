//
//  NewsViewController.swift
//  Life
//
//  Created by Shyngys Kassymov on 22.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import IGListKit
import Lightbox
import Material
import SnapKit

class NewsViewController: ASViewController<ASCollectionNode>, Stepper {

    private var listAdapter: ListAdapter!
    private var collectionNode: ASCollectionNode {
        return node
    }
    private lazy var spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    private lazy var refreshCtrl = UIRefreshControl()

    var viewModel: NewsItemViewModel!

    var onUnathorizedError: (() -> Void)?

    init(viewModel: NewsItemViewModel) {
        self.viewModel = viewModel

        let layout = UICollectionViewFlowLayout()
        layout.sectionFootersPinToVisibleBounds = true
        let node = ASCollectionNode(collectionViewLayout: layout)

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

        collectionNode.view.backgroundColor = .white
        collectionNode.view.alwaysBounceVertical = true

        let ratio: CGFloat = 360.0 / 300.0
        let width = UIScreen.main.bounds.size.width
        let height = width / ratio

        collectionNode.view.scrollIndicatorInsets = .init(
            top: height,
            left: 0,
            bottom: 0,
            right: 0)

        refreshCtrl = UIRefreshControl()
        refreshCtrl.addTarget(self, action: #selector(refreshFeed), for: .valueChanged)
        refreshCtrl.tintColor = App.Color.azure
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

    private func open(image: URL, allImages: [URL]) {
        guard !allImages.isEmpty else { return }

        let images = allImages.map { LightboxImage(imageURL: $0) }
        let startIndex = allImages.index(of: image) ?? 0

        let controller = LightboxController(images: images, startIndex: startIndex)
        controller.dynamicBackground = true

        present(controller, animated: true, completion: nil)
    }

}

extension NewsViewController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return [viewModel]
    }

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        let section = NewsDetailSectionController(
            viewModel: viewModel,
            didTapClose: { [weak self] in
                self?.step.accept(AppStep.newsDone)
            },
            didTapImage: { [weak self] (tappedImageURL, imageURLs) in
                self?.open(image: tappedImageURL, allImages: imageURLs)
            }
        )
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
        return nil
    }
}
