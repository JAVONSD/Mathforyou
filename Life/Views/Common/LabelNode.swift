//
//  LabelNode.swift
//  Life
//
//  Created by Shyngys Kassymov on 01.04.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import Kingfisher

class LabelNode: ASCellNode {

    private(set) var backgroundNode: RoundedNode!
    private(set) var labelNode: ASTextNode!

    init(text: String, corners: UIRectCorner = []) {
        super.init()

        backgroundNode = RoundedNode()
        backgroundNode.corners = corners
        backgroundNode.backgroundColor = .white
        backgroundNode.zPosition = App.Layout.zPositionCommon
        addSubnode(backgroundNode)

        labelNode = ASTextNode()
        labelNode.attributedText = att(text: text.uppercased())
        backgroundNode.addSubnode(labelNode)
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        backgroundNode.layoutSpecBlock = { (_, _) in
            return ASInsetLayoutSpec(insets: .init(
                top: App.Layout.itemSpacingMedium,
                left: App.Layout.sideOffset,
                bottom: App.Layout.itemSpacingMedium,
                right: App.Layout.sideOffset), child: self.labelNode
            )
        }
        backgroundNode.style.minWidth = ASDimension(
            unit: .points,
            value: constrainedSize.max.width - 2 * App.Layout.itemSpacingSmall
        )

        return ASWrapperLayoutSpec(layoutElement: backgroundNode)
    }

    // MARK: - Methods

    private func att(text: String) -> NSAttributedString {
        let attText = NSMutableAttributedString(string: text)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let allRange = NSRange(location: 0, length: attText.length)
        attText.addAttribute(.font, value: App.Font.navButton, range: allRange)
        attText.addAttribute(.foregroundColor, value: App.Color.azure, range: allRange)
        attText.addAttribute(.paragraphStyle, value: paragraphStyle, range: allRange)

        return attText
    }

}
