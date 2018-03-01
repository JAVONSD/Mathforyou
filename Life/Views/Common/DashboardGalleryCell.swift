//
//  DashboardGalleryCell.swift
//  Life
//
//  Created by Shyngys Kassymov on 20.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import Kingfisher

class DashboardGalleryCell: ASCellNode {

    struct Config {
        var image: String
        var title: String
        var corners: UIRectCorner
        var images: [String]
        var didTapOnImage: ((Int) -> Void)?
    }

    private(set) var backgroundNode: RoundedNode!
    private(set) var imageNode: ASNetworkImageNode!
    private(set) var titleNode: ASTextNode!
    private(set) var collectionNode: ASCollectionNode!

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

    private func addBackgroundNode(_ config: DashboardGalleryCell.Config) {
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

        titleNode = ASTextNode()
        titleNode.attributedText = attTitle(config.title)
        titleNode.maximumNumberOfLines = 1
        backgroundNode.addSubnode(titleNode)

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = App.Layout.itemSpacingSmall
        layout.sectionInset = .init(
            top: App.Layout.itemSpacingMedium,
            left: App.Layout.itemSpacingMedium,
            bottom: App.Layout.itemSpacingMedium,
            right: App.Layout.itemSpacingMedium
        )

        collectionNode = ASCollectionNode(collectionViewLayout: layout)
        collectionNode.backgroundColor = .clear
        collectionNode.dataSource = self
        collectionNode.delegate = self
        backgroundNode.addSubnode(collectionNode)
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        backgroundNode.layoutSpecBlock = { (_, _) in
            return self.backgroundSpec(constrainedSize)
        }

        return ASInsetLayoutSpec(insets: .init(
            top: App.Layout.itemSpacingSmall,
            left: App.Layout.itemSpacingSmall,
            bottom: 0,
            right: App.Layout.itemSpacingSmall), child: backgroundNode)
    }

    private func backgroundSpec(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let imageTitleStackSpeck = ASStackLayoutSpec.horizontal()
        imageTitleStackSpeck.children = [imageNode, titleNode]
        imageTitleStackSpeck.spacing = App.Layout.itemSpacingSmall

        let imageTitleInsetSpec = ASInsetLayoutSpec(insets: .init(
            top: App.Layout.itemSpacingSmall,
            left: App.Layout.itemSpacingSmall,
            bottom: 0,
            right: App.Layout.itemSpacingSmall), child: imageTitleStackSpeck)

        collectionNode.style.preferredSize = CGSize(
            width: constrainedSize.max.width,
            height: 88
        )

        let horizontalStackSpec = ASStackLayoutSpec.vertical()
        horizontalStackSpec.children = [imageTitleInsetSpec, collectionNode]

        return horizontalStackSpec
    }

    override func didLoad() {
        super.didLoad()

        ImageDownloader.download(image: config.image) { (image) in
            self.imageNode.image = image
        }

        collectionNode.view.showsHorizontalScrollIndicator = false
    }

    // MARK: - Methods

    private func attTitle(_ string: String) -> NSMutableAttributedString {
        let attText = NSMutableAttributedString(string: string.uppercased())

        let allRange = NSRange(location: 0, length: attText.length)
        attText.addAttribute(.font, value: App.Font.caption, range: allRange)
        attText.addAttribute(.foregroundColor, value: App.Color.slateGrey, range: allRange)

        return attText
    }

}

extension DashboardGalleryCell: ASCollectionDataSource, ASCollectionDelegate {
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }

    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return config.images.count
    }

    func collectionNode(
        _ collectionNode: ASCollectionNode,
        nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        return {
            return ImageNode(
                image: self.config.images[indexPath.item],
                size: CGSize(width: 56, height: 56),
                imageIsAvatar: true
            )
        }
    }

    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        if let didTapOnImage = config.didTapOnImage {
            didTapOnImage(indexPath.item)
        }
    }
}
