//
//  TopAuthorsCell.swift
//  Life
//
//  Created by Shyngys Kassymov on 22.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class TopAuthorsCell: ASCellNode {

    private(set) var titleNode: ASTextNode!
    private(set) var collectionNode: ASCollectionNode!
    private(set) var authorNameNode: ASTextNode!
    private(set) var authorJobPositionNode: ASTextNode!

    private(set) var likesImageNode: ASImageNode!
    private(set) var likesNode: ASTextNode!

    private(set) var viewsImageNode: ASImageNode!
    private(set) var viewsNode: ASTextNode!

    private(set) weak var viewModel: TopQuestionsViewModel?
    var didSelectItem: ((Int) -> Void)?

    init(viewModel: TopQuestionsViewModel) {
        self.viewModel = viewModel

        super.init()

        titleNode = ASTextNode()
        titleNode.attributedText = attTitle(NSLocalizedString("questions", comment: ""))
        addSubnode(titleNode)

        addCollectionNode()

        authorNameNode = ASTextNode()
        if let author = viewModel.topAnswerAuthors.first?.author {
            authorNameNode.attributedText = attAuthorName(author.name)
        }
        addSubnode(authorNameNode)

        authorJobPositionNode = ASTextNode()
        if let author = viewModel.topAnswerAuthors.first?.author {
            authorJobPositionNode.attributedText = attDetailText(author.jobPosition)
        }
        addSubnode(authorJobPositionNode)

        likesImageNode = ASImageNode()
        likesImageNode.image = #imageLiteral(resourceName: "like-inactive")
        if let author = viewModel.topAnswerAuthors.first?.author {
            likesImageNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(
                author.isLikedByMe ? App.Color.azure : App.Color.coolGrey
            )
        }
        addSubnode(likesImageNode)

        likesNode = ASTextNode()
        if let author = viewModel.topAnswerAuthors.first?.author {
            likesNode.attributedText = attDetailText("\(author.likesQuantity)")
        }
        addSubnode(likesNode)

        viewsImageNode = ASImageNode()
        viewsImageNode.image = #imageLiteral(resourceName: "view")
        viewsImageNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(
            App.Color.silver
        )
        addSubnode(viewsImageNode)

        viewsNode = ASTextNode()
        if let author = viewModel.topAnswerAuthors.first?.author {
            viewsNode.attributedText = attDetailText("\(author.viewsQuantity)")
        }
        addSubnode(viewsNode)
    }

    private func addCollectionNode() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = App.Layout.itemSpacingSmall
        layout.minimumLineSpacing = App.Layout.itemSpacingSmall
        layout.sectionInset = .init(
            top: App.Layout.itemSpacingMedium,
            left: App.Layout.sideOffset,
            bottom: App.Layout.itemSpacingMedium,
            right: App.Layout.sideOffset
        )
        collectionNode = ASCollectionNode(collectionViewLayout: layout)
        collectionNode.backgroundColor = .clear
        collectionNode.dataSource = self
        collectionNode.delegate = self
        collectionNode.shadowColor = App.Color.black12.cgColor
        collectionNode.shadowOffset = CGSize(width: 0, height: App.Layout.cornerRadiusSmall)
        collectionNode.shadowRadius = App.Layout.sideOffset
        collectionNode.shadowOpacity = 1
        collectionNode.clipsToBounds = false
        addSubnode(collectionNode)
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        collectionNode.style.preferredSize = CGSize(
            width: constrainedSize.max.width,
            height: 105
        )

        likesImageNode.style.preferredSize = CGSize(
            width: App.Layout.sideOffset,
            height: App.Layout.sideOffset
        )

        viewsImageNode.style.preferredSize = CGSize(
            width: App.Layout.sideOffset,
            height: App.Layout.sideOffset
        )

        let titleSpec = ASInsetLayoutSpec(insets: .init(
            top: App.Layout.sideOffset,
            left: App.Layout.sideOffset,
            bottom: 0,
            right: App.Layout.sideOffset), child: titleNode)

        let authorSpec = ASStackLayoutSpec.vertical()
        authorSpec.children = [authorNameNode, authorJobPositionNode]

        let likesSpec = ASStackLayoutSpec.vertical()
        likesSpec.children = [likesImageNode, likesNode]
        likesSpec.spacing = 2
        likesSpec.alignItems = .center

        let viewsSpec = ASStackLayoutSpec.vertical()
        viewsSpec.children = [viewsImageNode, viewsNode]
        viewsSpec.spacing = 2
        viewsSpec.alignItems = .center

        let likesViewsSpec = ASStackLayoutSpec.horizontal()
        likesViewsSpec.children = [likesSpec, viewsSpec]
        likesViewsSpec.spacing = App.Layout.itemSpacingSmall

        let footerSpec = ASStackLayoutSpec.horizontal()
        footerSpec.children = [authorSpec, likesViewsSpec]
        footerSpec.justifyContent = .spaceBetween
        footerSpec.alignItems = .center
        footerSpec.spacing = App.Layout.itemSpacingSmall

        let footerInsetSpec = ASInsetLayoutSpec(insets: .init(
            top: 0,
            left: App.Layout.sideOffset,
            bottom: App.Layout.itemSpacingSmall,
            right: App.Layout.sideOffset), child: footerSpec)

        let stackSpec = ASStackLayoutSpec.vertical()
        stackSpec.children = [titleSpec, collectionNode, footerInsetSpec]
        return stackSpec
    }

    // MARK: - Methods

    private func attAuthorName(_ string: String) -> NSMutableAttributedString {
        let attText = NSMutableAttributedString(string: string)

        let allRange = NSRange(location: 0, length: attText.length)
        attText.addAttribute(.font, value: App.Font.bodyAlts, range: allRange)
        attText.addAttribute(.foregroundColor, value: UIColor.black, range: allRange)

        return attText
    }

    private func attDetailText(_ string: String) -> NSMutableAttributedString {
        let attText = NSMutableAttributedString(string: string)

        let allRange = NSRange(location: 0, length: attText.length)
        attText.addAttribute(.font, value: App.Font.caption, range: allRange)
        attText.addAttribute(.foregroundColor, value: App.Color.steel, range: allRange)

        return attText
    }

    private func attTitle(_ string: String) -> NSMutableAttributedString {
        let attText = NSMutableAttributedString(string: string)

        let allRange = NSRange(location: 0, length: attText.length)
        attText.addAttribute(.font, value: App.Font.headline, range: allRange)
        attText.addAttribute(.foregroundColor, value: UIColor.black, range: allRange)

        return attText
    }

}

extension TopAuthorsCell: ASCollectionDataSource {
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }

    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.topAnswerAuthors.count ?? 0
    }

    func collectionNode(
        _ collectionNode: ASCollectionNode,
        nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        return { [weak self] in
            guard let `self` = self, let viewModel = self.viewModel else {
                return ASCellNode()
            }
            let size = CGSize(width: 72, height: 72)
            let image = viewModel.topAnswerAuthors[indexPath.item].author.code
            return ImageNode(image: image, size: size, backgroundColor: .white)
        }
    }
}

extension TopAuthorsCell: ASCollectionDelegate {
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        if let didSelectItem = didSelectItem {
            didSelectItem(indexPath.item)
        }
    }
}
