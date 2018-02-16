//
//  OverviewCell.swift
//  Life
//
//  Created by Shyngys Kassymov on 16.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import DynamicColor

class OverviewCell: ASCellNode {

    private(set) var bodyNode: ASDisplayNode!
    private(set) var imageNode: ASNetworkImageNode!
    private(set) var titleNode: ASTextNode!
    private(set) var itemsCountNode: ASTextNode!

    init(viewModel: LentaViewModel, entityType: EntityType) {
        super.init()

        backgroundColor = .clear
        clipsToBounds = false

        shadowColor = App.Color.black12.cgColor
        shadowOffset = CGSize(width: 0, height: App.Layout.cornerRadiusSmall)
        shadowRadius = App.Layout.cornerRadiusSmall
        shadowOpacity = 1

        bodyNode = ASDisplayNode()
        bodyNode.backgroundColor = .white
        bodyNode.cornerRadius = App.Layout.cornerRadius
        bodyNode.clipsToBounds = true
        addSubnode(bodyNode)

        var imageColor = UIColor(hexString: "#50e3c2")
        var title = NSLocalizedString("news", comment: "")
        var count = viewModel.items.filter { $0.entityType == .news }.count

        if entityType == .questionnaire {
            imageColor = UIColor(hexString: "#4a90e2")
            count = viewModel.items.filter { $0.entityType == .questionnaire }.count
            title = NSLocalizedString("questionnaires", comment: "")
        } else if entityType == .suggestion {
            imageColor = UIColor(hexString: "#f5a623")
            count = viewModel.items.filter { $0.entityType == .suggestion }.count
            title = NSLocalizedString("suggestions", comment: "")
        }

        titleNode = ASTextNode()
        titleNode.attributedText = attTitleText(title)
        bodyNode.addSubnode(titleNode)

        itemsCountNode = ASTextNode()
        itemsCountNode.attributedText = attDetailText("\(count)")
        bodyNode.addSubnode(itemsCountNode)

        imageNode = ASNetworkImageNode()
        imageNode.backgroundColor = imageColor
        bodyNode.addSubnode(imageNode)
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        style.preferredSize = CGSize(width: 128, height: 112)

        bodyNode.layoutSpecBlock = { (_, _) in
            return self.bodySpec()
        }
        bodyNode.style.preferredSize = CGSize(width: 112, height: 96)

        let bodyInsetSpec = ASInsetLayoutSpec(insets: .init(
            top: App.Layout.itemSpacingMedium / 2,
            left: App.Layout.itemSpacingMedium / 2,
            bottom: App.Layout.itemSpacingMedium / 2,
            right: App.Layout.itemSpacingMedium / 2), child: bodyNode)
        return bodyInsetSpec
    }

    // MARK: - Methods

    private func bodySpec() -> ASLayoutSpec {
        let textStack = ASStackLayoutSpec.horizontal()
        textStack.children = [titleNode, itemsCountNode]
        textStack.spacing = App.Layout.itemSpacingSmall / 2
        textStack.alignItems = .center

        let textInsetSpec = ASInsetLayoutSpec(insets: .init(
            top: App.Layout.itemSpacingSmall,
            left: 12,
            bottom: 10,
            right: 0), child: textStack)

        imageNode.style.preferredSize = CGSize(width: 112, height: 64)

        let finalSpec = ASStackLayoutSpec.vertical()
        finalSpec.children = [textInsetSpec, imageNode]

        return finalSpec
    }

    private func attTitleText(_ string: String) -> NSMutableAttributedString {
        let attText = NSMutableAttributedString(string: string)

        let allRange = NSMakeRange(0, attText.length)
        attText.addAttribute(.font, value: App.Font.captionAlts, range: allRange)
        attText.addAttribute(.foregroundColor, value: UIColor.black, range: allRange)

        return attText
    }

    private func attDetailText(_ string: String) -> NSMutableAttributedString {
        let attText = NSMutableAttributedString(string: string)

        let allRange = NSMakeRange(0, attText.length)
        attText.addAttribute(.font, value: App.Font.caption, range: allRange)
        attText.addAttribute(.foregroundColor, value: App.Color.steel, range: allRange)

        return attText
    }

}
