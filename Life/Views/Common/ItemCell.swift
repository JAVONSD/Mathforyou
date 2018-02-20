//
//  ItemCell.swift
//  Life
//
//  Created by Shyngys Kassymov on 20.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class ItemCell: ASCellNode {

    struct SeparatorInset {
        var left: CGFloat
        var right: CGFloat

        var totalInsets: CGFloat {
            return left + right
        }
    }

    private(set) var backgroundNode: RoundedNode!
    private(set) var titleNode: ASTextNode!
    private(set) var subtitleNode: ASTextNode!
    private(set) var separatorNode: ASDisplayNode!

    private(set) var separatorLeftRightInset: SeparatorInset
    private(set) var bottomInset: CGFloat

    init(title: String,
         subtitle: String,
         separatorLeftRightInset: SeparatorInset = SeparatorInset(
            left: App.Layout.itemSpacingMedium,
            right: App.Layout.itemSpacingMedium),
         bottomInset: CGFloat = App.Layout.itemSpacingSmall,
         separatorHidden: Bool = false,
         corners: UIRectCorner = []) {
        self.separatorLeftRightInset = separatorLeftRightInset
        self.bottomInset = bottomInset

        super.init()

        zPosition = App.Layout.zPositionCommon - 1

        shadowColor = App.Color.black12.cgColor
        shadowRadius = App.Layout.sideOffset
        shadowOffset = CGSize(width: 0, height: App.Layout.itemSpacingSmall)
        shadowOpacity = 1

        backgroundNode = RoundedNode()
        backgroundNode.corners = corners
        backgroundNode.backgroundColor = .white
        backgroundNode.zPosition = App.Layout.zPositionCommon
        addSubnode(backgroundNode)

        separatorNode = ASDisplayNode()
        separatorNode.backgroundColor = App.Color.coolGrey
        separatorNode.isHidden = separatorHidden
        backgroundNode.addSubnode(separatorNode)

        titleNode = ASTextNode()
        titleNode.attributedText = attTitle(title)
        backgroundNode.addSubnode(titleNode)

        subtitleNode = ASTextNode()
        subtitleNode.attributedText = attSubtitle(subtitle)
        backgroundNode.addSubnode(subtitleNode)
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        backgroundNode.layoutSpecBlock = { (_, range) in
            return self.backgroundSpec(range)
        }

        return ASInsetLayoutSpec(insets: .init(
            top: 0,
            left: App.Layout.itemSpacingSmall,
            bottom: 0,
            right: App.Layout.itemSpacingSmall), child: backgroundNode)
    }

    private func backgroundSpec(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let textStackSpec = ASStackLayoutSpec.vertical()
        textStackSpec.children = [titleNode, subtitleNode]

        let textInsetSpec = ASInsetLayoutSpec(insets: .init(
            top: App.Layout.itemSpacingSmall,
            left: App.Layout.itemSpacingMedium * 2,
            bottom: bottomInset,
            right: App.Layout.itemSpacingMedium * 2), child: textStackSpec)

        separatorNode.style.preferredSize = CGSize(
            width: constrainedSize.max.width - separatorLeftRightInset.totalInsets,
            height: 0.5
        )

        let separatorInsetSpec = ASInsetLayoutSpec(insets: .init(
            top: 0,
            left: separatorLeftRightInset.left,
            bottom: 0,
            right: separatorLeftRightInset.right), child: separatorNode)

        let verticalStackSpec = ASStackLayoutSpec.vertical()
        verticalStackSpec.children = [separatorInsetSpec, textInsetSpec]
        return verticalStackSpec
    }

    // MARK: - Methods

    private func attTitle(_ string: String) -> NSMutableAttributedString {
        let attText = NSMutableAttributedString(string: string)

        let allRange = NSRange(location: 0, length: attText.length)
        attText.addAttribute(.font, value: App.Font.body, range: allRange)
        attText.addAttribute(.foregroundColor, value: UIColor.black, range: allRange)

        return attText
    }

    private func attSubtitle(_ string: String) -> NSMutableAttributedString {
        let attText = NSMutableAttributedString(string: string)

        let allRange = NSRange(location: 0, length: attText.length)
        attText.addAttribute(.font, value: App.Font.caption, range: allRange)
        attText.addAttribute(.foregroundColor, value: App.Color.steel, range: allRange)

        return attText
    }

}
