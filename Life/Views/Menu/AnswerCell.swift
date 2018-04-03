//
//  AnswerCell.swift
//  Life
//
//  Created by Shyngys Kassymov on 22.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import Hue
import Kingfisher
import AVFoundation

class AnswerCell: ASCellNode {

    private(set) var backgroundNode: ASDisplayNode!

    private(set) var authorImageNode: ASNetworkImageNode!
    private(set) var authorNameNode: ASTextNode!
    private(set) var dateNode: ASTextNode!

    private(set) var textNode: ASTextNode!
    private(set) var imageNode: ASImageNode!

    private(set) var likesImageNode: ASImageNode!
    private(set) var likesNode: ASTextNode!

    private var answer: Answer

    init(viewModel: AnswerViewModel) {
        answer = viewModel.answer

        super.init()

        backgroundNode = ASDisplayNode()
        backgroundNode.backgroundColor = App.Color.paleGrey
        backgroundNode.cornerRadius = App.Layout.cornerRadiusSmall
        addSubnode(backgroundNode)

        authorImageNode = ASNetworkImageNode()
        authorImageNode.contentMode = .scaleAspectFill
        authorImageNode.cornerRadius = 6
        authorImageNode.image = #imageLiteral(resourceName: "ic-user")
        backgroundNode.addSubnode(authorImageNode)

        authorNameNode = ASTextNode()
        authorNameNode.attributedText = attAuthorName(viewModel.answer.authorName)
        backgroundNode.addSubnode(authorNameNode)

        dateNode = ASTextNode()
        dateNode.attributedText = attDetailText(
            viewModel.answer.createDate.prettyDateOrTimeAgoString(format: "dd MMMM yyyy")
        )
        backgroundNode.addSubnode(dateNode)

        if answer.videoStreamId.isEmpty {
            textNode = ASTextNode()
            textNode.attributedText = attText(viewModel.answer.text)
            backgroundNode.addSubnode(textNode)
        } else {
            imageNode = ASImageNode()
            imageNode.cornerRadius = App.Layout.cornerRadiusSmall
            imageNode.contentMode = .scaleAspectFill
            backgroundNode.addSubnode(imageNode)
        }

        likesImageNode = ASImageNode()
        likesImageNode.image = #imageLiteral(resourceName: "like-inactive")
        likesImageNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(
            viewModel.answer.isLikedByMe ? App.Color.azure : App.Color.coolGrey
        )
        backgroundNode.addSubnode(likesImageNode)

        likesNode = ASTextNode()
        likesNode.attributedText = attDetailText("\(viewModel.answer.likesQuantity)")
        backgroundNode.addSubnode(likesNode)
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        backgroundNode.layoutSpecBlock = { (_, _) in
            return self.backgroundSpec(constrainedSize)
        }
        backgroundNode.style.minWidth = ASDimension(unit: .points, value: constrainedSize.max.width)
        backgroundNode.style.maxWidth = ASDimension(unit: .points, value: constrainedSize.max.width)

        let insetSpec = ASInsetLayoutSpec(insets: .init(
            top: App.Layout.itemSpacingSmall,
            left: App.Layout.sideOffset,
            bottom: App.Layout.itemSpacingSmall,
            right: App.Layout.sideOffset), child: backgroundNode)

        return insetSpec
    }

    private func backgroundSpec(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        authorImageNode.style.preferredSize = CGSize(
            width: App.Layout.itemSpacingMedium,
            height: App.Layout.itemSpacingMedium
        )

        likesImageNode.style.preferredSize = CGSize(
            width: App.Layout.sideOffset,
            height: App.Layout.sideOffset
        )

        let headerSpec = ASStackLayoutSpec.horizontal()
        headerSpec.children = [authorImageNode, authorNameNode, dateNode]
        headerSpec.spacing = App.Layout.itemSpacingSmall
        headerSpec.alignItems = .center

        let likesSpec = ASStackLayoutSpec.horizontal()
        likesSpec.children = [likesImageNode, likesNode]
        likesSpec.spacing = App.Layout.itemSpacingSmall / 2
        likesSpec.alignItems = .center

        let contentNode = !answer.videoStreamId.isEmpty ? imageNode : textNode
        if !answer.videoStreamId.isEmpty {
            let ratio: CGFloat = 192.0 / 134.0
            let width = constrainedSize.max.width - 2 * (App.Layout.itemSpacingSmall + App.Layout.sideOffset)
            let height = width / ratio
            contentNode.style.preferredSize = CGSize(width: width, height: height)
        }

        let stackSpec = ASStackLayoutSpec.vertical()
        stackSpec.children = [headerSpec, contentNode, likesSpec]
        stackSpec.spacing = App.Layout.itemSpacingSmall

        let insetSpec = ASInsetLayoutSpec(insets: .init(
            top: App.Layout.itemSpacingSmall,
            left: App.Layout.itemSpacingSmall,
            bottom: App.Layout.itemSpacingSmall,
            right: App.Layout.itemSpacingSmall), child: stackSpec)

        return insetSpec
    }

    override func didLoad() {
        super.didLoad()

        ImageDownloader.download(
            image: "",
            employeeCode: answer.authorCode,
            placeholderImage: #imageLiteral(resourceName: "ic-user"),
            size: CGSize(
                width: App.Layout.itemSpacingMedium,
                height: App.Layout.itemSpacingMedium
            )) { (image) in
            self.authorImageNode.image = image
        }

        if !answer.videoStreamId.isEmpty {
            DispatchQueue.global().async { [weak self] in
                guard let `self` = self else { return }
                self.imageNode.image = ImageDownloader.createThumbnailOfVideo(from: self.answer.videoStreamId)
            }
        }
    }

    // MARK: - Methods

    private func attAuthorName(_ string: String) -> NSMutableAttributedString {
        let attText = NSMutableAttributedString(string: string)

        let allRange = NSRange(location: 0, length: attText.length)
        attText.addAttribute(.font, value: App.Font.captionAlts, range: allRange)
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

    private func attText(_ string: String) -> NSMutableAttributedString {
        let attText = NSMutableAttributedString(string: string)

        let allRange = NSRange(location: 0, length: attText.length)
        attText.addAttribute(.font, value: App.Font.caption, range: allRange)
        attText.addAttribute(.foregroundColor, value: UIColor.black, range: allRange)

        return attText
    }

}
