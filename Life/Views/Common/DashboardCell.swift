//
//  DashboardCell.swift
//  Life
//
//  Created by Shyngys Kassymov on 19.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import Kingfisher

class DashboardCell: ASCellNode {

    struct Config {
        var image: String
        var title: String
        var itemColor: UIColor = UIColor.black
        var item1Count: Int
        var item1Title: String
        var item2Count: Int
        var item2Title: String
        var item3Count: Int
        var item3Title: String
        var showAddButton: Bool
        var corners: UIRectCorner
        var minimized: Bool
        var didTapAddButton: (() -> Void)?
    }

    var didTapToggle: (() -> Void)?
    var didTapAdd: (() -> Void)?

    private(set) var backgroundNode: RoundedNode!
    private(set) var imageNode: ASNetworkImageNode!
    private(set) var toggleNode: ASButtonNode!

    private(set) var item1CountNode: ASTextNode!
    private(set) var item1TitleNode: ASTextNode!

    private(set) var separator1Node: ASDisplayNode!

    private(set) var item2CountNode: ASTextNode!
    private(set) var item2TitleNode: ASTextNode!

    private(set) var separator2Node: ASDisplayNode!

    private(set) var item3CountNode: ASTextNode!
    private(set) var item3TitleNode: ASTextNode!

    private(set) var addNode: ASButtonNode!

    private(set) var config: Config

    init(config: Config) {
        self.config = config

        super.init()

        shadowColor = App.Color.black12.cgColor
        shadowRadius = App.Layout.sideOffset
        shadowOffset = CGSize(width: 0, height: App.Layout.itemSpacingSmall)
        shadowOpacity = 1

        zPosition = App.Layout.zPositionCommon - 1

        addBackgroundNode(config)
    }

    fileprivate func addItem1Nodes(_ config: DashboardCell.Config) {
        item1CountNode = ASTextNode()
        item1CountNode.attributedText = attItemCount("\(config.item1Count)")
        item1CountNode.maximumNumberOfLines = 1
        backgroundNode.addSubnode(item1CountNode)

        item1TitleNode = ASTextNode()
        item1TitleNode.attributedText = attItemTitle(config.item1Title)
        item1TitleNode.maximumNumberOfLines = 1
        backgroundNode.addSubnode(item1TitleNode)
    }

    fileprivate func addItem2Nodes(_ config: DashboardCell.Config) {
        item2CountNode = ASTextNode()
        item2CountNode.attributedText = attItemCount("\(config.item1Count)")
        item2CountNode.maximumNumberOfLines = 1
        backgroundNode.addSubnode(item2CountNode)

        item2TitleNode = ASTextNode()
        item2TitleNode.attributedText = attItemTitle(config.item1Title)
        item2TitleNode.maximumNumberOfLines = 1
        backgroundNode.addSubnode(item2TitleNode)
    }

    fileprivate func addItem3Nodes(_ config: DashboardCell.Config) {
        item3CountNode = ASTextNode()
        item3CountNode.attributedText = attItemCount("\(config.item1Count)")
        item3CountNode.maximumNumberOfLines = 1
        backgroundNode.addSubnode(item3CountNode)

        item3TitleNode = ASTextNode()
        item3TitleNode.attributedText = attItemTitle(config.item1Title)
        item3TitleNode.maximumNumberOfLines = 1
        backgroundNode.addSubnode(item3TitleNode)
    }

    private func addItemsAndSeparators(_ config: DashboardCell.Config) {
        addItem1Nodes(config)

        separator1Node = ASDisplayNode()
        separator1Node.backgroundColor = App.Color.paleGreyTwo
        separator1Node.style.preferredSize = .init(
            width: 0.5,
            height: App.Layout.itemSpacingMedium
        )
        backgroundNode.addSubnode(separator1Node)

        addItem2Nodes(config)

        separator2Node = ASDisplayNode()
        separator2Node.backgroundColor = App.Color.paleGreyTwo
        separator2Node.style.preferredSize = .init(
            width: 0.5,
            height: App.Layout.itemSpacingMedium
        )
        backgroundNode.addSubnode(separator2Node)

        addItem3Nodes(config)
    }

    private func addBackgroundNode(_ config: DashboardCell.Config) {
        backgroundNode = RoundedNode()
        backgroundNode.corners = config.corners
        backgroundNode.backgroundColor = .white
        backgroundNode.zPosition = App.Layout.zPositionCommon
        addSubnode(backgroundNode)

        imageNode = ASNetworkImageNode()
        imageNode.backgroundColor = App.Color.paleGreyTwo
        imageNode.cornerRadius = App.Layout.cornerRadiusSmall / 2
        imageNode.contentMode = .scaleAspectFill
        imageNode.style.preferredSize = CGSize(
            width: App.Layout.itemSpacingMedium,
            height: App.Layout.itemSpacingMedium
        )
        backgroundNode.addSubnode(imageNode)

        toggleNode = ASButtonNode()
        toggleNode.addTarget(self, action: #selector(handleToggle), forControlEvents: .touchUpInside)
        toggleNode.setAttributedTitle(attTitle(config.title), for: .normal)
        toggleNode.contentHorizontalAlignment = .left
        toggleNode.imageAlignment = .end
        let image = config.minimized ? #imageLiteral(resourceName: "expand_arrow") : #imageLiteral(resourceName: "collapse_arrow")
        toggleNode.setImage(image, for: .normal)
        toggleNode.imageNode.style.preferredSize = CGSize(
            width: App.Layout.itemSpacingSmall,
            height: App.Layout.itemSpacingSmall
        )
        toggleNode.imageNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(
            App.Color.slateGrey
        )
        backgroundNode.addSubnode(toggleNode)

        addItemsAndSeparators(config)

        addNode = ASButtonNode()
        addNode.addTarget(self, action: #selector(handleAddButton), forControlEvents: .touchUpInside)
        addNode.setImage(#imageLiteral(resourceName: "button-flat"), for: .normal)
        let addSize = App.Layout.sideOffset + App.Layout.itemSpacingMedium * 2
        addNode.style.preferredSize = CGSize(
            width: addSize,
            height: addSize
        )
        addNode.cornerRadius = addSize / 2
        backgroundNode.addSubnode(addNode)
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        backgroundNode.layoutSpecBlock = { (_, _) in
            return self.backgroundSpec(constrainedSize)
        }
        backgroundNode.style.preferredSize = CGSize(
            width: constrainedSize.max.width - 2 * App.Layout.itemSpacingSmall,
            height: 72
        )

        return ASInsetLayoutSpec(insets: .init(
            top: App.Layout.itemSpacingSmall,
            left: App.Layout.itemSpacingSmall,
            bottom: 0,
            right: App.Layout.itemSpacingSmall), child: backgroundNode)
    }

    private func backgroundSpec(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        toggleNode.style.flexGrow = 1.0
        toggleNode.style.minHeight = ASDimension(unit: .points, value: App.Layout.itemSpacingMedium * 2)

        let imageTitleStackSpeck = ASStackLayoutSpec.horizontal()
        imageTitleStackSpeck.children = [imageNode, toggleNode]
        imageTitleStackSpeck.spacing = App.Layout.itemSpacingSmall
        imageTitleStackSpeck.alignItems = .center

        let imageTitleInsetSpec = ASInsetLayoutSpec(insets: .init(
            top: 0,
            left: App.Layout.itemSpacingSmall,
            bottom: 0,
            right: App.Layout.itemSpacingSmall), child: imageTitleStackSpeck)

        let leftStackSpec = ASStackLayoutSpec.vertical()
        leftStackSpec.children = [imageTitleInsetSpec, itemsSpec()]
        leftStackSpec.style.flexGrow = 1.0

        let rightInsetSpec = ASInsetLayoutSpec(insets: .init(
            top: App.Layout.itemSpacingMedium,
            left: 1,
            bottom: 0,
            right: 1), child: addNode)

        let horizontalStackSpec = ASStackLayoutSpec.horizontal()
        horizontalStackSpec.children = [leftStackSpec, rightInsetSpec]
        horizontalStackSpec.alignContent = .spaceBetween
        horizontalStackSpec.style.flexGrow = 1.0

        return horizontalStackSpec
    }

    private func itemsSpec() -> ASLayoutSpec {
        let item1StackSpec = ASStackLayoutSpec.horizontal()
        item1StackSpec.children = [item1CountNode, item1TitleNode]
        item1StackSpec.spacing = App.Layout.itemSpacingSmall / 2
        item1StackSpec.alignItems = .center

        let item2StackSpec = ASStackLayoutSpec.horizontal()
        item2StackSpec.children = [item2CountNode, item2TitleNode]
        item2StackSpec.spacing = App.Layout.itemSpacingSmall / 2
        item2StackSpec.alignItems = .center

        let item3StackSpec = ASStackLayoutSpec.horizontal()
        item3StackSpec.children = [item3CountNode, item3TitleNode]
        item3StackSpec.spacing = App.Layout.itemSpacingSmall / 2
        item3StackSpec.alignItems = .center

        let itemsStackSpec = ASStackLayoutSpec.horizontal()
        itemsStackSpec.children = [
            item1StackSpec,
            separator1Node,
            item2StackSpec,
            separator2Node,
            item3StackSpec
        ]
        itemsStackSpec.spacing = App.Layout.itemSpacingSmall

        let itemsInsetSpec = ASInsetLayoutSpec(insets: .init(
            top: App.Layout.itemSpacingSmall,
            left: App.Layout.itemSpacingMedium * 2,
            bottom: App.Layout.itemSpacingSmall / 2 * 3,
            right: App.Layout.itemSpacingMedium * 2), child: itemsStackSpec)

        return itemsInsetSpec
    }

    override func didLoad() {
        super.didLoad()

        let modifier = AnyModifier { request in
            var r = request
            let token = User.current.token ?? ""
            r.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            return r
        }

        if let url = URL(string: config.image) {
            ImageDownloader
                .default
                .downloadImage(
                    with: url,
                    options: [.requestModifier(modifier)],
                    progressBlock: nil) { (image, _, _, _) in
                        self.imageNode.image = image
            }
        }

        toggleNode.view.tintColor = App.Color.slateGrey
    }

    // MARK: - Actions

    @objc
    private func handleToggle() {
        if let didTapToggle = didTapToggle {
            didTapToggle()
        }
    }

    @objc
    private func handleAddButton() {
        if let didTapAdd = didTapAdd {
            didTapAdd()
        }
    }

    // MARK: - Methods

    private func attTitle(_ string: String) -> NSMutableAttributedString {
        let attText = NSMutableAttributedString(string: string.uppercased())

        let allRange = NSRange(location: 0, length: attText.length)
        attText.addAttribute(.font, value: App.Font.caption, range: allRange)
        attText.addAttribute(.foregroundColor, value: App.Color.slateGrey, range: allRange)

        return attText
    }

    private func attItemCount(_ string: String) -> NSMutableAttributedString {
        let attText = NSMutableAttributedString(string: string)

        let allRange = NSRange(location: 0, length: attText.length)
        attText.addAttribute(.font, value: App.Font.subheadAlts, range: allRange)
        attText.addAttribute(.foregroundColor, value: config.itemColor, range: allRange)

        return attText
    }

    private func attItemTitle(_ string: String) -> NSMutableAttributedString {
        let attText = NSMutableAttributedString(string: string)

        let allRange = NSRange(location: 0, length: attText.length)
        attText.addAttribute(.font, value: App.Font.caption, range: allRange)
        attText.addAttribute(.foregroundColor, value: App.Color.steel, range: allRange)

        return attText
    }

}
