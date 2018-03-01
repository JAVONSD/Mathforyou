//
//  NewsHeaderNode.swift
//  Life
//
//  Created by Shyngys Kassymov on 22.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class NewsHeaderNode: ASDisplayNode {

    private(set) var collectionNode: ASCollectionNode!

    private(set) var overlayNode: ASDisplayNode!

    private(set) var labelContainerNode: ASDisplayNode!
    private(set) var labelNode: ASTextNode!

    private(set) var closeNode: ASButtonNode!

    private(set) var pageControl: UIPageControl!
    private(set) var pageControlNode: ASDisplayNode!

    private(set) var news: News
    private var images: [String] {
        var items = news.secondaryImages.map { $0.streamId }
        if !news.imageUrl.isEmpty {
            items.insert(news.imageUrl, at: 0)
        }
        return items
    }

    private(set) var didTapClose: (() -> Void)?

    init(news: News,
         didTapClose: @escaping (() -> Void)) {
        self.news = news
        self.didTapClose = didTapClose

        super.init()

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = .zero
        collectionNode = ASCollectionNode(collectionViewLayout: layout)
        collectionNode.backgroundColor = .clear
        collectionNode.dataSource = self
        collectionNode.delegate = self
        addSubnode(collectionNode)

        overlayNode = ASDisplayNode()
        overlayNode.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        overlayNode.isUserInteractionEnabled = false
        addSubnode(overlayNode)

        labelContainerNode = ASDisplayNode()
        labelContainerNode.backgroundColor = .white
        labelContainerNode.cornerRadius = App.Layout.cornerRadiusSmall / 2
        labelContainerNode.style.flexShrink = 1.0
        addSubnode(labelContainerNode)

        labelNode = ASTextNode()
        labelNode.attributedText = attLabel(news.title)
        labelNode.style.flexShrink = 1.0
        labelContainerNode.addSubnode(labelNode)

        closeNode = ASButtonNode()
        closeNode.addTarget(self, action: #selector(handleCloseButton), forControlEvents: .touchUpInside)
        closeNode.setImage(#imageLiteral(resourceName: "close-circle"), for: .normal)
        addSubnode(closeNode)

        pageControlNode = ASDisplayNode(viewBlock: { () -> UIView in
            self.pageControl = UIPageControl(frame: .init(x: 0, y: 0, width: 100, height: 20))
            self.pageControl.backgroundColor = .white
            self.pageControl.numberOfPages = self.images.count
            self.pageControl.currentPage = 0
            self.pageControl.hidesForSinglePage = true
            self.pageControl.pageIndicatorTintColor = App.Color.slateGrey.withAlphaComponent(0.32)
            self.pageControl.currentPageIndicatorTintColor = App.Color.slateGrey
            return self.pageControl
        })
        pageControlNode.backgroundColor = .white
        addSubnode(pageControlNode)
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        closeNode.style.preferredSize = CGSize(
            width: 40,
            height: 40
        )
        collectionNode.style.preferredSize = collectionSize()
        pageControlNode.style.preferredSize = CGSize(
            width: constrainedSize.max.width,
            height: 20
        )

        labelContainerNode.layoutSpecBlock = { (_, _) in
            return ASInsetLayoutSpec(insets: .init(
                top: 1,
                left: App.Layout.itemSpacingSmall / 2,
                bottom: 1,
                right: App.Layout.itemSpacingSmall / 2), child: self.labelNode)
        }

        let horizStackSpec = ASStackLayoutSpec.horizontal()
        horizStackSpec.children = [self.labelContainerNode, self.closeNode]
        horizStackSpec.alignItems = .center
        horizStackSpec.justifyContent = .spaceBetween
        horizStackSpec.spacing = App.Layout.sideOffset
        horizStackSpec.style.flexShrink = 1.0

        let vertStackSpec = ASStackLayoutSpec.vertical()
        vertStackSpec.children = [horizStackSpec]
        vertStackSpec.justifyContent = .start
        vertStackSpec.style.flexShrink = 1.0

        let insetSpec = ASInsetLayoutSpec(insets: .init(
            top: App.Layout.itemSpacingMedium,
            left: App.Layout.sideOffset,
            bottom: 0,
            right: App.Layout.itemSpacingMedium), child: vertStackSpec)
        insetSpec.style.flexShrink = 1.0

        let labelCloseOverlaySpec = ASOverlayLayoutSpec(child: overlayNode, overlay: insetSpec)
        let overlaySpec = ASOverlayLayoutSpec(child: collectionNode, overlay: labelCloseOverlaySpec)

        let stackSpec = ASStackLayoutSpec.vertical()
        stackSpec.children = [overlaySpec, pageControlNode]
        return stackSpec
    }

    override func didLoad() {
        super.didLoad()

        collectionNode.view.showsHorizontalScrollIndicator = false
        collectionNode.view.isPagingEnabled = true
    }

    // MARK: - Actions

    @objc
    private func handleCloseButton() {
        if let didTapClose = didTapClose {
            didTapClose()
        }
    }

    // MARK: - Methods

    private func attLabel(_ string: String) -> NSMutableAttributedString {
        let attText = NSMutableAttributedString(string: string)

        let allRange = NSRange(location: 0, length: attText.length)
        attText.addAttribute(.font, value: App.Font.label, range: allRange)
        attText.addAttribute(.foregroundColor, value: App.Color.slateGrey, range: allRange)

        return attText
    }

    private func collectionSize() -> CGSize {
        let width = UIScreen.main.bounds.size.width

        if images.isEmpty {
            return CGSize(width: width, height: 70)
        }

        let ratio: CGFloat = 360.0 / 300.0
        let height = width / ratio

        let size = CGSize(width: width, height: height)
        return size
    }

}

extension NewsHeaderNode: ASCollectionDataSource {
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }

    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    func collectionNode(
        _ collectionNode: ASCollectionNode,
        nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        return { [weak self] in
            guard let `self` = self else {
                return ASCellNode()
            }

            let image = self.images[indexPath.item]
            return ImageNode(
                image: image,
                size: self.collectionSize(),
                cornerRadius: 0
            )
        }
    }
}

extension NewsHeaderNode: ASCollectionDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.frame.size.width
        let page = (scrollView.contentOffset.x + 0.5 * width) / width
        self.pageControl.currentPage = max(min(Int(page), images.count - 1), 0)
    }
}
