//
//  SlideCell.swift
//  Life
//
//  Created by Shyngys Kassymov on 19.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import Kingfisher

class SlideCell: ASCellNode {

    private(set) var labelContainerNode: ASDisplayNode!
    private(set) var labelNode: ASTextNode!
    private(set) var imageNode: ASNetworkImageNode!
    private(set) var imageCoverNode: ASDisplayNode!
    private(set) var titleNode: ASTextNode!

    private(set) var slide: SliderViewModel
    private(set) var width: CGFloat
    private(set) var height: CGFloat

    var leftInset: CGFloat = 0

    var didSelectSlide: ((_ index: Int) -> Void)?

    init(slide: SliderViewModel,
         width: CGFloat,
         height: CGFloat,
         slideCornerRadius: CGFloat) {
        
        self.slide = slide
        self.width = width
        self.height = height

        super.init()

        cornerRadius = slideCornerRadius

        imageNode = ASNetworkImageNode()
        imageNode.backgroundColor = UIColor.white
        imageNode.contentMode = .scaleAspectFill
        addSubnode(imageNode)

        imageCoverNode = ASDisplayNode()
        imageCoverNode.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        imageNode.addSubnode(imageCoverNode)

        labelContainerNode = ASDisplayNode()
        labelContainerNode.backgroundColor = .white
        labelContainerNode.style.alignSelf = .start
        labelContainerNode.cornerRadius = App.Layout.cornerRadiusSmall / 2
        imageCoverNode.addSubnode(labelContainerNode)

        labelNode = ASTextNode()
        labelNode.attributedText = attLabel(slide.label)
        labelContainerNode.addSubnode(labelNode)

        titleNode = ASTextNode()
        titleNode.attributedText = attTitle(slide.title)
        titleNode.maximumNumberOfLines = 2
        imageCoverNode.addSubnode(titleNode)
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        labelContainerNode.layoutSpecBlock = { (_, _) in
            let spec = ASInsetLayoutSpec(insets: .init(
                top: 1,
                left: App.Layout.itemSpacingSmall / 2,
                bottom: 1,
                right: App.Layout.itemSpacingSmall / 2), child: self.labelNode)
            return spec
        }

        imageCoverNode.layoutSpecBlock = { (_, _) in
            let verticalSpec = ASStackLayoutSpec.vertical()
            verticalSpec.children = [self.labelContainerNode, self.titleNode]
            verticalSpec.justifyContent = .spaceBetween

            return ASInsetLayoutSpec(insets: .init(
                top: App.Layout.itemSpacingMedium,
                left: App.Layout.sideOffset + self.leftInset,
                bottom: App.Layout.itemSpacingBig,
                right: App.Layout.sideOffset - self.leftInset), child: verticalSpec)
        }

        imageNode.layoutSpecBlock = { (_, _) in
            let spec = ASWrapperLayoutSpec(layoutElement: self.imageCoverNode)
            return spec
        }

        let spec = ASWrapperLayoutSpec(layoutElement: imageNode)
        spec.style.preferredSize = CGSize(
            width: width,
            height: height
        )
        return spec
    }

    override func didLoad() {
        super.didLoad()

        ImageDownloader.download(image: slide.image) { (image) in
            self.imageNode.image = image
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

    private func attTitle(_ string: String) -> NSMutableAttributedString {
        let attText = NSMutableAttributedString(string: string)

        let allRange = NSRange(location: 0, length: attText.length)
        attText.addAttribute(.font, value: App.Font.titleSmall, range: allRange)
        attText.addAttribute(.foregroundColor, value: UIColor.white, range: allRange)

        return attText
    }

}
