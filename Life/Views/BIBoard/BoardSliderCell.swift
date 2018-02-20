//
//  BoardSliderCell.swift
//  Life
//
//  Created by Shyngys Kassymov on 16.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class BoardSliderCell: ASCellNode {

    private(set) var collectionNode: ASCollectionNode!
    private(set) var pageNode: ASDisplayNode!
    private(set) var pageControl: UIPageControl!

    private(set) var slides: [SliderViewModel]
    private(set) var height: CGFloat

    private let pageControlHeight: CGFloat = 20
    private var slidesCornerRadius: CGFloat

    var didSelectSlide: ((_ index: Int) -> Void)?

    private(set) var layout: UICollectionViewFlowLayout

    init(slides: [SliderViewModel],
         height: CGFloat,
         layout: UICollectionViewFlowLayout? = nil,
         slidesCornerRadius: CGFloat = 0) {
        self.slides = slides
        self.height = height
        self.slidesCornerRadius = slidesCornerRadius

        let defaultLayout = UICollectionViewFlowLayout()
        defaultLayout.scrollDirection = .horizontal
        defaultLayout.minimumInteritemSpacing = 0
        defaultLayout.minimumLineSpacing = 0
        defaultLayout.sectionInset = .zero

        let theLayout = layout ?? defaultLayout
        self.layout = theLayout

        super.init()

        clipsToBounds = false

        collectionNode = ASCollectionNode(collectionViewLayout: self.layout)
        collectionNode.backgroundColor = .clear
        collectionNode.dataSource = self
        addSubnode(collectionNode)

        pageNode = ASDisplayNode(viewBlock: { () -> UIView in
            self.pageControl = UIPageControl(frame: .init(
                x: 0, y: 0, width: 100, height: self.pageControlHeight))
            self.pageControl.backgroundColor = .clear
            self.pageControl.numberOfPages = self.slides.count
            self.pageControl.currentPage = 0
            self.pageControl.pageIndicatorTintColor = App.Color.slateGrey.withAlphaComponent(0.32)
            self.pageControl.currentPageIndicatorTintColor = App.Color.slateGrey
            return self.pageControl
        })
        pageNode.backgroundColor = .clear
        pageNode.style.preferredSize = CGSize(
            width: 100,
            height: pageControlHeight
        )
        addSubnode(pageNode)
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        collectionNode.style.preferredSize = CGSize(
            width: constrainedSize.max.width,
            height: height - pageControlHeight
        )

        let verticalStack = ASStackLayoutSpec.vertical()
        verticalStack.children = [
            collectionNode,
            pageNode
        ]
        verticalStack.alignItems = .center

        verticalStack.style.preferredSize = CGSize(
            width: constrainedSize.max.width,
            height: height
        )

        return verticalStack
    }

    override func didLoad() {
        super.didLoad()

        collectionNode.view.isPagingEnabled = true
        collectionNode.view.showsHorizontalScrollIndicator = false
    }

    // MARK: - Methods

    private func attText(_ string: String) -> NSMutableAttributedString {
        let attText = NSMutableAttributedString(string: string)

        let allRange = NSRange(location: 0, length: attText.length)
        attText.addAttribute(.font, value: App.Font.headline, range: allRange)
        attText.addAttribute(.foregroundColor, value: UIColor.black, range: allRange)

        return attText
    }

}

extension BoardSliderCell: ASCollectionDataSource, ASCollectionDelegate {
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }

    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return slides.count
    }

    func collectionNode(
        _ collectionNode: ASCollectionNode,
        nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        return {
            let slide = self.slides[indexPath.item]
            let cell = SlideCell(
                slide: slide,
                width: UIScreen.main.bounds.size.width - self.layout.sectionInset.left * 2,
                height: self.height - self.pageControlHeight,
                slideCornerRadius: self.slidesCornerRadius
            )
            return cell
        }
    }

    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        if let didSelectSlide = didSelectSlide {
            didSelectSlide(indexPath.item)
        }
    }
}
