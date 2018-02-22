//
//  TopQuestionsHeader.swift
//  Life
//
//  Created by Shyngys Kassymov on 22.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class TopQuestionsHeader: ASCellNode {

    private(set) var separatorNode: ASDisplayNode!
    private(set) var titleNode: ASTextNode!

    init(title: String) {
        super.init()

        separatorNode = ASDisplayNode()
        separatorNode.backgroundColor = App.Color.coolGrey
        addSubnode(separatorNode)

        titleNode = ASTextNode()
        titleNode.attributedText = attTitle(title)
        addSubnode(titleNode)
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        separatorNode.style.preferredSize = CGSize(
            width: constrainedSize.max.width - 2 * App.Layout.sideOffset,
            height: 0.5
        )

        let stackSpec = ASStackLayoutSpec.vertical()
        stackSpec.children = [separatorNode, titleNode]
        stackSpec.spacing = App.Layout.sideOffset

        let insetSpec = ASInsetLayoutSpec(insets: .init(
            top: App.Layout.itemSpacingSmall,
            left: App.Layout.sideOffset,
            bottom: App.Layout.itemSpacingSmall,
            right: App.Layout.sideOffset), child: stackSpec)

        return insetSpec
    }

    // MARK: - Methods

    private func attTitle(_ string: String) -> NSMutableAttributedString {
        let attText = NSMutableAttributedString(string: string.uppercased())

        let allRange = NSRange(location: 0, length: attText.length)
        attText.addAttribute(.font, value: App.Font.label, range: allRange)
        attText.addAttribute(.foregroundColor, value: App.Color.slateGrey, range: allRange)

        return attText
    }

}
