//
//  TopAnswersCell.swift
//  Life
//
//  Created by Shyngys Kassymov on 22.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class TopAnswersCell: ASCellNode {

    private(set) var collectionNode: ASCollectionNode!

    private(set) weak var viewModel: AnswersViewModel?
    var didSelectVideo: ((String) -> Void)?

    init(viewModel: AnswersViewModel) {
        self.viewModel = viewModel

        super.init()

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = App.Layout.itemSpacingSmall
        layout.minimumLineSpacing = App.Layout.itemSpacingSmall
        layout.sectionInset = .init(
            top: App.Layout.itemSpacingSmall,
            left: App.Layout.sideOffset,
            bottom: App.Layout.itemSpacingSmall,
            right: App.Layout.sideOffset
        )
        collectionNode = ASCollectionNode(collectionViewLayout: layout)
        collectionNode.backgroundColor = .clear
        collectionNode.dataSource = self
        collectionNode.delegate = self
        addSubnode(collectionNode)
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        collectionNode.style.preferredSize = CGSize(
            width: constrainedSize.max.width,
            height: 150
        )

        return ASWrapperLayoutSpec(layoutElement: collectionNode)
    }

}

extension TopAnswersCell: ASCollectionDataSource {
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }

    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.videoAnswers.count ?? 0
    }

    func collectionNode(
        _ collectionNode: ASCollectionNode,
        nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        return { [weak self] in
            guard let `self` = self,
                let viewModel = self.viewModel else {
                    return ASCellNode()
            }

            var size = CGSize(width: 112, height: 63)
            if indexPath.item == 0 {
                size = CGSize(width: 192, height: 134)
            }

            let video = viewModel.videoAnswers[indexPath.item].answer.videoStreamId
            return VideoNode(video: video, size: size, cornerRadius: App.Layout.cornerRadiusSmall)
        }
    }
}

extension TopAnswersCell: ASCollectionDelegate {
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        guard let viewModel = self.viewModel,
            let didSelectVideo = didSelectVideo else {
            return
        }

        let video = viewModel.videoAnswers[indexPath.item].answer.videoStreamId
        didSelectVideo(video)
    }
}
