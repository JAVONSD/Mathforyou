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

class LentaViewController: ASViewController<ASDisplayNode>, FABMenuDelegate {

    private var listAdapter: ListAdapter!
    private(set) var collectionNode: ASCollectionNode!
    private(set) lazy var spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    private lazy var refreshCtrl = UIRefreshControl()

    private var fabButton: FABButton!
    private var fabMenu: FABMenu!

    var viewModel: LentaViewModel!

    var onUnathorizedError: (() -> Void)?

    var didTapNews: ((String) -> Void)?
    var didTapSuggestion: ((String) -> Void)?
    var didTapAddNews: ((@escaping ((News, ImageSize) -> Void)) -> Void)?
    var didTapAddSuggestion: ((@escaping ((Suggestion, ImageSize) -> Void)) -> Void)?

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
            self.fabButton = FABButton(image: Icon.cm.add, tintColor: .white)
            self.fabButton.pulseColor = .white
            self.fabButton.backgroundColor = App.Color.azure
            self.fabButton.shadowColor = App.Color.black12
            self.fabButton.depth = Depth(offset: Offset.init(horizontal: 0, vertical: 12), opacity: 1, radius: 12)

            self.fabMenu = FABMenu()
            self.fabMenu.delegate = self
            self.fabMenu.fabButton = self.fabButton
            self.fabMenu.fabMenuItemSize = CGSize(
                width: App.Layout.itemSpacingMedium * 2,
                height: App.Layout.itemSpacingMedium * 2
            )
            self.setupFABMenuItems()
            self.fabMenu.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 56, height: 56))
            }
            return self.fabMenu
        }
        addNode.backgroundColor = .clear
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
            didTapAddNews { [weak self] (news, imageSize) in
                guard let `self` = self else { return }

                var lentaItem = Lenta(news: news)
                lentaItem.imageSize = imageSize
                self.viewModel.add(item: lentaItem)

                let newsSC = self.listAdapter.sectionController(for: self.viewModel) as? NewsSectionController
                newsSC?.updateContents()
            }
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

    private func setupFABMenuItems() {
        let addNewsItem = setupFABMenuItem(
            title: NSLocalizedString("add_news", comment: ""),
            onTap: { [weak self] in
            if let didTapAddNews = self?.didTapAddNews {
                didTapAddNews { [weak self] (news, imageSize) in
                    guard let `self` = self else { return }

                    var lentaItem = Lenta(news: news)
                    lentaItem.imageSize = imageSize
                    self.viewModel.add(item: lentaItem)

                    let newsSC = self.listAdapter.sectionController(for: self.viewModel) as? NewsSectionController
                    newsSC?.updateContents()
                }
            }
        })
        let addSuggestionItem = setupFABMenuItem(
            title: NSLocalizedString("new_suggestion", comment: ""),
            onTap: { [weak self] in
            if let didTapAddSuggestion = self?.didTapAddSuggestion {
                didTapAddSuggestion { [weak self] (suggestion, imageSize) in
                    guard let `self` = self else { return }

                    var lentaItem = Lenta(suggestion: suggestion)
                    lentaItem.imageSize = imageSize
                    self.viewModel.add(item: lentaItem)

                    let newsSC = self.listAdapter.sectionController(for: self.viewModel) as? NewsSectionController
                    newsSC?.updateContents()
                }
            }
        })

        fabMenu.fabMenuItems = [addNewsItem, addSuggestionItem].reversed()
    }

    private func setupFABMenuItem(title: String, onTap: @escaping (() -> Void)) -> FABMenuItem {
        let menuItem = FABMenuItem()
        menuItem.title = title
        menuItem.titleLabel.backgroundColor = .clear
        menuItem.titleLabel.font = App.Font.body
        menuItem.titleLabel.textColor = .black
        menuItem.fabButton.image = Icon.cm.add
        menuItem.fabButton.tintColor = .white
        menuItem.fabButton.pulseColor = .white
        menuItem.fabButton.backgroundColor = App.Color.azure
        menuItem.fabButton.rx.tap.asDriver().throttle(0.5).drive(onNext: {
            onTap()

            self.fabMenuWillClose(fabMenu: self.fabMenu)
            self.fabMenu.close()
        }).disposed(by: disposeBag)

        return menuItem
    }

    // MARK: - FABMenuDelegate

    func fabMenuWillOpen(fabMenu: FABMenu) {
        collectionNode.alpha = 0.15

        fabButton.backgroundColor = App.Color.paleGreyTwo
        fabButton.image = Icon.cm.close
        fabButton.tintColor = App.Color.coolGrey
    }

    func fabMenuWillClose(fabMenu: FABMenu) {
        collectionNode.alpha = 1

        fabButton.backgroundColor = App.Color.azure
        fabButton.image = Icon.cm.add
        fabButton.tintColor = UIColor.white
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
