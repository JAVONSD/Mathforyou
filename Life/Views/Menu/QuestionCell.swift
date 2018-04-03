//
//  QuestionCell.swift
//  Life
//
//  Created by Shyngys Kassymov on 22.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import Hue
import Kingfisher

class QuestionCell: ASCellNode {

    private(set) var backgroundNode: ASDisplayNode!

    private(set) var authorImageNode: ASNetworkImageNode!
    private(set) var authorNameNode: ASTextNode!
    private(set) var dateNode: ASTextNode!

    private(set) var textNode: ASTextNode!

    private(set) var likesImageNode: ASImageNode!
    private(set) var likesNode: ASTextNode!

    private(set) var answersImageNode: ASImageNode!
    private(set) var answersNode: ASTextNode!

    private var question: Question
    init(viewModel: QuestionItemViewModel) {
        question = viewModel.question

        super.init()

        backgroundNode = ASDisplayNode()
        addSubnode(backgroundNode)

        authorImageNode = ASNetworkImageNode()
        authorImageNode.contentMode = .scaleAspectFill
        authorImageNode.cornerRadius = 6
        authorImageNode.image = #imageLiteral(resourceName: "ic-user")
        backgroundNode.addSubnode(authorImageNode)

        authorNameNode = ASTextNode()
        authorNameNode.attributedText = attAuthorName(viewModel.question.authorName)
        backgroundNode.addSubnode(authorNameNode)

        dateNode = ASTextNode()
        dateNode.attributedText = attDetailText(
            viewModel.question.createDate.prettyDateOrTimeAgoString(format: "dd MMMM yyyy")
        )
        backgroundNode.addSubnode(dateNode)

        textNode = ASTextNode()
        textNode.attributedText = attText(viewModel.question.text)
        backgroundNode.addSubnode(textNode)

        likesImageNode = ASImageNode()
        likesImageNode.image = #imageLiteral(resourceName: "like-inactive")
        likesImageNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(
            viewModel.question.isLikedByMe ? App.Color.azure : App.Color.coolGrey
        )
        backgroundNode.addSubnode(likesImageNode)

        likesNode = ASTextNode()
        likesNode.attributedText = attDetailText("\(viewModel.question.likesQuantity)")
        backgroundNode.addSubnode(likesNode)

        answersImageNode = ASImageNode()
        answersImageNode.image = #imageLiteral(resourceName: "chat-inactive")
        answersImageNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(
            App.Color.coolGrey
        )
        backgroundNode.addSubnode(answersImageNode)

        answersNode = ASTextNode()
        let text = !viewModel.question.answers.isEmpty
            ? NSLocalizedString("answer_exists", comment: "")
            : NSLocalizedString("answer_does_not_exist", comment: "")
        answersNode.attributedText = attDetailText(text)
        backgroundNode.addSubnode(answersNode)
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        backgroundNode.layoutSpecBlock = { (_, _) in
            return self.backgroundSpec()
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

    private func backgroundSpec() -> ASLayoutSpec {
        authorImageNode.style.preferredSize = CGSize(
            width: App.Layout.itemSpacingMedium,
            height: App.Layout.itemSpacingMedium
        )

        likesImageNode.style.preferredSize = CGSize(
            width: App.Layout.sideOffset,
            height: App.Layout.sideOffset
        )

        answersImageNode.style.preferredSize = CGSize(
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

        let answersSpec = ASStackLayoutSpec.horizontal()
        answersSpec.children = [answersImageNode, answersNode]
        answersSpec.spacing = App.Layout.itemSpacingSmall / 2
        answersSpec.alignItems = .center

        let footerSpec = ASStackLayoutSpec.horizontal()
        footerSpec.children = [likesSpec, answersSpec]
        footerSpec.spacing = App.Layout.itemSpacingSmall
        footerSpec.alignItems = .center

        let stackSpec = ASStackLayoutSpec.vertical()
        stackSpec.children = [headerSpec, textNode, footerSpec]
        stackSpec.spacing = App.Layout.itemSpacingSmall

        return stackSpec
    }

    override func didLoad() {
        super.didLoad()

        ImageDownloader.download(
            image: "",
            employeeCode: question.authorCode,
            placeholderImage: #imageLiteral(resourceName: "ic-user"),
            size: CGSize(
                width: App.Layout.itemSpacingMedium,
                height: App.Layout.itemSpacingMedium
            )) { (image) in
            self.authorImageNode.image = image
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
