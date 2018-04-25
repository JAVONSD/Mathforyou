//
//  SuggestionViewController.swift
//  Life
//
//  Created by Shyngys Kassymov on 23.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import IGListKit
import Lightbox
import Material
import NVActivityIndicatorView
import RxSwift
import SnapKit

class SuggestionViewController: ASViewController<ASDisplayNode>, Stepper {

    private var listAdapter: ListAdapter!
    private(set) var collectionNode: ASCollectionNode!

    private var spinnerNode: ASDisplayNode!
    private(set) lazy var spinner = NVActivityIndicatorView(
        frame: .init(x: 0, y: 0, width: 44, height: 44),
        type: .circleStrokeSpin,
        color: App.Color.azure,
        padding: 0)

    private lazy var refreshCtrl = UIRefreshControl()

    private var fabButton: FABButton!

    var viewModel: SuggestionItemViewModel!

    var onUnathorizedError: (() -> Void)?

    init(viewModel: SuggestionItemViewModel) {
        self.viewModel = viewModel

        let node = ASDisplayNode()
        super.init(node: node)

        setupNodes()

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

        bind()
    }

    // MARK: - Actions

    @objc
    private func handleShareButton() {
        let text = viewModel.suggestion.title

        let textType = "Предложение"
        let link = LinkBuilder.newsLink(for: viewModel.suggestion.id)

        let shareText =
        """
        \(textType): "\(text)"
        Автор: \(viewModel.suggestion.authorName)
        Ссылка: \(link)
        """

        let shareItems = [shareText]
        let activityViewController = UIActivityViewController(
            activityItems: shareItems,
            applicationActivities: nil
        )
        activityViewController.popoverPresentationController?.sourceView = self.view

        present(activityViewController, animated: true, completion: nil)
    }

    // MARK: - Bind

    private func bind() {
        viewModel.loading.asDriver()
            .drive(onNext: { [weak self] loading in
                guard let `self` = self else { return }
                loading ? self.spinner.startAnimating() : self.spinner.stopAnimating()
                self.spinnerNode.isHidden = !loading
                self.fabButton.isHidden = loading
            })
            .disposed(by: disposeBag)
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

        var images = allImages.map { LightboxImage(imageURL: $0) }
        let startIndex = allImages.index(of: image) ?? 0

        if !image.absoluteString.hasPrefix("http://") && !image.absoluteString.hasPrefix("https://") {
            images = allImages.map { url -> LightboxImage in
                guard let data = try? Data.init(contentsOf: url),
                    let image = UIImage(data: data) else {
                        return LightboxImage(imageURL: url)
                }
                return LightboxImage(image: image)
            }
        }

        let controller = LightboxController(images: images, startIndex: startIndex)
        controller.dynamicBackground = true

        present(controller, animated: true, completion: nil)
    }

    private func setupFABButton() {
        fabButton = FABButton(image: Icon.cm.share, tintColor: .white)
        fabButton.addTarget(self, action: #selector(handleShareButton), for: .touchUpInside)
        fabButton.pulseColor = .white
        fabButton.backgroundColor = App.Color.azure
        fabButton.shadowColor = App.Color.black12
        fabButton.depth = Depth(offset: Offset.init(horizontal: 0, vertical: 12), opacity: 1, radius: 12)
        fabButton.isHidden = true
    }

    // MARK: - UI

    private func setupNodes() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionFootersPinToVisibleBounds = true
        collectionNode = ASCollectionNode(collectionViewLayout: layout)
        node.addSubnode(collectionNode)

        let fabNode = ASDisplayNode { () -> UIView in
            self.setupFABButton()
            let view = UIView()
            view.backgroundColor = .clear
            view.addSubview(self.fabButton)
            self.fabButton.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 56, height: 56))
                make.edges.equalTo(view)
            }
            return view
        }
        fabNode.backgroundColor = .clear
        fabNode.style.preferredSize = CGSize(width: 56, height: 56)
        node.addSubnode(fabNode)

        spinnerNode = ASDisplayNode(viewBlock: { () -> UIView in
            self.spinner.startAnimating()
            return self.spinner
        })
        spinnerNode.backgroundColor = .clear
        spinnerNode.style.preferredSize = CGSize(width: 44, height: 44)
        node.addSubnode(spinnerNode)

        node.layoutSpecBlock = { (_, _) in
            let insetSpec = ASInsetLayoutSpec(insets: .init(
                top: 0,
                left: 0,
                bottom: 30,
                right: App.Layout.sideOffset), child: fabNode)
            let relativeSpec = ASRelativeLayoutSpec(
                horizontalPosition: .end,
                verticalPosition: .end,
                sizingOption: [],
                child: insetSpec
            )
            let collectionSpec = ASOverlayLayoutSpec(child: self.collectionNode, overlay: relativeSpec)

            let spinnerSpec = ASStackLayoutSpec.vertical()
            spinnerSpec.children = [self.spinnerNode]
            spinnerSpec.alignItems = .center
            spinnerSpec.justifyContent = .center

            let spinnerInsetSpect = ASInsetLayoutSpec(
                insets: .init(top: 70, left: 0, bottom: 0, right: 0),
                child: spinnerSpec
            )

            return ASOverlayLayoutSpec(child: collectionSpec, overlay: spinnerInsetSpect)
        }
    }

}

extension SuggestionViewController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return [viewModel]
    }

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        let section = SuggestionSectionController(
            viewModel: viewModel,
            didTapClose: { [weak self] in
                self?.step.accept(AppStep.suggestionDone)
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
