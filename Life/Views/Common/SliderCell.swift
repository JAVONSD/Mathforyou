//
//  SliderCell.swift
//  Life
//
//  Created by Shyngys Kassymov on 19.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class SliderCell: ASCellNode {

    private(set) var collectionNode: ASCollectionNode!
    private(set) weak var viewModel: LentaViewModel?

    init(viewModel: LentaViewModel) {
        super.init()

        self.viewModel = viewModel

        clipsToBounds = false

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = .init(
            top: App.Layout.itemSpacingMedium / 2,
            left: App.Layout.sideOffset - App.Layout.itemSpacingMedium / 2,
            bottom: App.Layout.itemSpacingMedium / 2 - App.Layout.itemSpacingSmall / 2,
            right: App.Layout.sideOffset
        )
        collectionNode = ASCollectionNode(collectionViewLayout: layout)
        collectionNode.backgroundColor = .clear
        collectionNode.dataSource = self
        addSubnode(collectionNode)
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        collectionNode.style.preferredSize = CGSize(
            width: constrainedSize.max.width,
            height: 124
        )

        let verticalStack = ASStackLayoutSpec.vertical()
        verticalStack.children = [collectionNode]

        return verticalStack
    }

    override func didLoad() {
        super.didLoad()

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

extension SliderCell: ASCollectionDataSource {
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }

    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return 3
    }

    func collectionNode(
        _ collectionNode: ASCollectionNode,
        nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        return { [weak self] in
            guard let `self` = self,
                let viewModel = self.viewModel else {
                    return ASCellNode()
            }
            var entityType = EntityType.news
            if indexPath.item == 1 {
                entityType = .questionnaire
            } else if indexPath.item == 2 {
                entityType = .suggestion
            }
            return OverviewCell(viewModel: viewModel, entityType: entityType)
        }
    }
}
