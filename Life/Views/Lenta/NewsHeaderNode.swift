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

    private(set) var labelContainerNode: ASDisplayNode!
    private(set) var labelNode: ASTextNode!

    private(set) var closeNode: ASButtonNode!

    private(set) var pageControl: UIPageControl!
    private(set) var pageControlNode: ASDisplayNode!

    private(set) var news: News
    private var images: [String] {
        return news.secondaryImages + [news.imageUrl]
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

        labelContainerNode = ASDisplayNode()
        labelContainerNode.backgroundColor = .white
        labelContainerNode.cornerRadius = App.Layout.cornerRadiusSmall / 2
        collectionNode.addSubnode(labelContainerNode)

        labelNode = ASTextNode()
        labelNode.attributedText = attLabel("SUBHEAD")
        labelContainerNode.addSubnode(labelNode)

        closeNode = ASButtonNode()
        closeNode.addTarget(self, action: #selector(handleCloseButton), forControlEvents: .touchUpInside)
        closeNode.setImage(#imageLiteral(resourceName: "close-circle"), for: .normal)
        collectionNode.addSubnode(closeNode)

        pageControlNode = ASDisplayNode(viewBlock: { () -> UIView in
            self.pageControl = UIPageControl(frame: .init(x: 0, y: 0, width: 100, height: 20))
            self.pageControl.backgroundColor = .white
            self.pageControl.numberOfPages = self.images.count
            self.pageControl.currentPage = 0
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

        collectionNode.layoutSpecBlock = { (_, _) in
            let labelSpec = ASInsetLayoutSpec(insets: .init(
                top: 10,
                left: 0,
                bottom: 0,
                right: 0), child: self.labelContainerNode)

            let horizStackSpec = ASStackLayoutSpec.horizontal()
            horizStackSpec.children = [labelSpec, self.closeNode]
            horizStackSpec.alignItems = .start
            horizStackSpec.justifyContent = .spaceBetween

            return ASInsetLayoutSpec(insets: .init(
                top: App.Layout.itemSpacingMedium,
                left: App.Layout.sideOffset,
                bottom: 0,
                right: App.Layout.itemSpacingMedium), child: horizStackSpec)
        }
        collectionNode.style.alignItems = .start
        collectionNode.style.alignSelf = .start

        let stackSpec = ASStackLayoutSpec.vertical()
        stackSpec.children = [collectionNode, pageControlNode]
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
        print("Handle close button ...")
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
        let ratio: CGFloat = 360.0 / 300.0
        let width = UIScreen.main.bounds.size.width
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
                cornerRadius: 0,
                overlayColor: UIColor.black.withAlphaComponent(0.3)
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
