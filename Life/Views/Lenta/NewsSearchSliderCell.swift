//
//  BoardSliderCell.swift
//  Life
//
//  Created by Kanat on 16.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import NVActivityIndicatorView
import RxSwift

class NewsSearchSliderCell: ASCellNode {
    
    let disposeBag = DisposeBag()
    
    private(set) var collectionNode: ASCollectionNode!
    
    private(set) var spinnerNode: ASDisplayNode!
    private(set) lazy var spinner = NVActivityIndicatorView(
        frame: .init(x: 0, y: 0, width: 44, height: 44),
        type: .circleStrokeSpin,
        color: App.Color.azure,
        padding: 0)
    
    private(set) var slides: [SliderViewModel]
    private(set) var height: CGFloat
    
    private var slidesCornerRadius: CGFloat
    
    var didSelectSlide: ((_ index: Int) -> Void)?
    
    private(set) var layout: UICollectionViewFlowLayout
    
    init(slides: [SliderViewModel],
         height: CGFloat,
         layout: UICollectionViewFlowLayout? = nil,
         slidesCornerRadius: CGFloat = 50,
         hideSpinner: Bool = true) {
        
        self.slides = slides
        self.height = height
        self.slidesCornerRadius = slidesCornerRadius
        
        let defaultLayout = UICollectionViewFlowLayout()
        defaultLayout.scrollDirection = .horizontal
        defaultLayout.minimumInteritemSpacing = 10
        defaultLayout.minimumLineSpacing = 10
        defaultLayout.sectionInset = .zero
        
        let theLayout = layout ?? defaultLayout
        self.layout = theLayout
        
        super.init()
        
        clipsToBounds = false
        
        collectionNode = ASCollectionNode(collectionViewLayout: self.layout)
        collectionNode.backgroundColor = .clear
        collectionNode.dataSource = self
        collectionNode.delegate = self
        addSubnode(collectionNode)

        spinnerNode = ASDisplayNode(viewBlock: { () -> UIView in
            if !hideSpinner {
                self.spinner.startAnimating()
            }
            return self.spinner
        })
        spinnerNode.backgroundColor = .clear
        spinnerNode.style.preferredSize = CGSize(width: 44, height: 44)
        spinnerNode.isHidden = hideSpinner
        addSubnode(spinnerNode)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        collectionNode.style.preferredSize = CGSize(
            width: constrainedSize.max.width,
            height: height
        )
        
        let verticalStack = ASStackLayoutSpec.vertical()
        verticalStack.children = [
            collectionNode]

        verticalStack.alignItems = .center
        
        verticalStack.style.preferredSize = CGSize(
            width: constrainedSize.max.width,
            height: height
        )
        
        let spinnerSpec = ASStackLayoutSpec.vertical()
        spinnerSpec.children = [spinnerNode]
        spinnerSpec.alignItems = .center
        spinnerSpec.justifyContent = .center
        
        return ASOverlayLayoutSpec(child: verticalStack, overlay: spinnerSpec)
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

extension NewsSearchSliderCell: ASCollectionDataSource, ASCollectionDelegate {
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
            let cell = NewsSearchHeaderCell(
                slide: slide,
                width: self.height,
                height: self.height,
                slideCornerRadius: self.height/2
            )
            return cell
        }
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        if let didSelectSlide = didSelectSlide {
            didSelectSlide(indexPath.item)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let width = scrollView.frame.size.width
//        let currentX = scrollView.contentOffset.x + 0.5 * width
//
//        for idx in 0..<slides.count {
//            if let cell = collectionNode.nodeForItem(at: IndexPath(item: idx, section: 0)) as? SlideCell {
//                let centerX = CGFloat(idx + 1) * width / 2 + CGFloat(idx) * width / 2
//                let offset = centerX - currentX
//                let percentage = offset / scrollView.contentSize.width
//                let maxOffsetDistance = scrollView.contentSize.width
//                let speed: CGFloat = 0.8
//                let currentOffset = maxOffsetDistance * percentage * speed
//                cell.leftInset = -currentOffset
//
//                cell.imageCoverNode.setNeedsLayout()
//                cell.imageCoverNode.layoutIfNeeded()
//            }
//        }
    }
}




