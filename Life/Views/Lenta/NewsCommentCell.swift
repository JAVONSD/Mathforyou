//
//  NewsCommentCell.swift
//  Life
//
//  Created by Shyngys Kassymov on 22.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import Kingfisher

class NewsCommentCell: ASCellNode {

    private(set) var backgroundNode: ASDisplayNode!

    private(set) var authorImageNode: ASNetworkImageNode!
    private(set) var authorNameNode: ASTextNode!
    private(set) var dateNode: ASTextNode!

    private(set) var textNode: ASTextNode!

    private(set) var likesImageNode: ASImageNode!
    private(set) var likesNode: ASTextNode!

    private(set) var dislikesImageNode: ASImageNode!
    private(set) var dislikesNode: ASTextNode!

    private var comment: Comment

    var didLikeComment: ((UserVote) -> Void)?

    init(comment: Comment) {
        self.comment = comment

        super.init()

        backgroundNode = ASDisplayNode()
        addSubnode(backgroundNode)

        authorImageNode = ASNetworkImageNode()
        authorImageNode.backgroundColor = UIColor(hexString: "#d8d8d8")
        authorImageNode.contentMode = .scaleAspectFill
        authorImageNode.cornerRadius = 6
        backgroundNode.addSubnode(authorImageNode)

        authorNameNode = ASTextNode()
        authorNameNode.attributedText = attAuthorName(comment.authorName)
        backgroundNode.addSubnode(authorNameNode)

        dateNode = ASTextNode()
        dateNode.attributedText = attDetailText(
            comment.createDate.prettyDateOrTimeAgoString(format: "dd MMMM yyyy"),
            textAlignment: .right
        )
        backgroundNode.addSubnode(dateNode)

        textNode = ASTextNode()
        textNode.attributedText = attText(comment.text)
        backgroundNode.addSubnode(textNode)

        setupLikesNodes(comment)
    }

    private func setupLikesNodes(_ comment: Comment) {
        likesImageNode = ASImageNode()
        likesImageNode.addTarget(
            self,
            action: #selector(handleLikeButton),
            forControlEvents: .touchUpInside
        )
        likesImageNode.image = #imageLiteral(resourceName: "like-inactive")
        likesImageNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(
            comment.getVote() == .liked ? App.Color.azure : App.Color.coolGrey
        )
        backgroundNode.addSubnode(likesImageNode)

        likesNode = ASTextNode()
        likesNode.attributedText = attDetailText("\(comment.likesQuantity)")
        backgroundNode.addSubnode(likesNode)

        dislikesImageNode = ASImageNode()
        dislikesImageNode.addTarget(
            self,
            action: #selector(handleDislikeButton),
            forControlEvents: .touchUpInside
        )
        dislikesImageNode.image = #imageLiteral(resourceName: "dislike-inactive")
        dislikesImageNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(
            comment.getVote() == .disliked ? App.Color.azure : App.Color.coolGrey
        )
        backgroundNode.addSubnode(dislikesImageNode)

        dislikesNode = ASTextNode()
        dislikesNode.attributedText = attDetailText("\(comment.dislikesQuantity)")
        backgroundNode.addSubnode(dislikesNode)
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        backgroundNode.layoutSpecBlock = { (_, _) in
            return self.backgroundSpec(constrainedSize)
        }
        backgroundNode.style.minWidth = ASDimension(
            unit: .points,
            value: constrainedSize.max.width - 2 * App.Layout.sideOffset
        )
        backgroundNode.style.maxWidth = ASDimension(
            unit: .points,
            value: constrainedSize.max.width - 2 * App.Layout.sideOffset
        )

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

        dislikesImageNode.style.preferredSize = CGSize(
            width: App.Layout.sideOffset,
            height: App.Layout.sideOffset
        )

        authorNameNode.style.flexShrink = 1.0
        dateNode.style.flexGrow = 1.0

        let headerSpec = ASStackLayoutSpec.horizontal()
        headerSpec.children = [authorImageNode, authorNameNode, dateNode]
        headerSpec.spacing = App.Layout.itemSpacingSmall
        headerSpec.alignItems = .center
        headerSpec.style.minWidth = ASDimension(
            unit: .points,
            value: constrainedSize.max.width - 2 * App.Layout.sideOffset
        )
        headerSpec.style.maxWidth = ASDimension(
            unit: .points,
            value: constrainedSize.max.width - 2 * App.Layout.sideOffset
        )

        let likesSpec = ASStackLayoutSpec.horizontal()
        likesSpec.children = [likesImageNode, likesNode]
        likesSpec.spacing = App.Layout.itemSpacingSmall / 2
        likesSpec.alignItems = .center

        let answersSpec = ASStackLayoutSpec.horizontal()
        answersSpec.children = [dislikesImageNode, dislikesNode]
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

        ImageDownloader.download(image: "", employeeCode: comment.authorCode) { (image) in
            self.authorImageNode.image = image
        }
    }

    // MARK: - Actions

    @objc
    private func handleLikeButton() {
        var vote = UserVote.liked
        var likesCount = comment.likesQuantity
        var dislikesCount = comment.dislikesQuantity
        if comment.getVote() == .liked {
            vote = .default
            likesCount -= 1
        } else if comment.getVote() == .default {
            likesCount += 1
        } else if comment.getVote() == .disliked {
            likesCount += 1
            dislikesCount -= 1
        }
        comment.set(vote: vote)
        comment.likesQuantity = likesCount
        comment.dislikesQuantity = dislikesCount

        updateLikeDislikeState()

        if let didLikeComment = didLikeComment {
            didLikeComment(vote)
        }
    }

    @objc
    private func handleDislikeButton() {
        var vote = UserVote.disliked
        var likesCount = comment.likesQuantity
        var dislikesCount = comment.dislikesQuantity
        if comment.getVote() == .disliked {
            vote = .default
            dislikesCount -= 1
        } else if comment.getVote() == .default {
            dislikesCount += 1
        } else if comment.getVote() == .liked {
            dislikesCount += 1
            likesCount -= 1
        }
        comment.set(vote: vote)
        comment.likesQuantity = likesCount
        comment.dislikesQuantity = dislikesCount

        updateLikeDislikeState()

        if let didLikeComment = didLikeComment {
            didLikeComment(vote)
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

    private func attDetailText(
        _ string: String,
        textAlignment: NSTextAlignment = .left) -> NSMutableAttributedString {
        let attText = NSMutableAttributedString(string: string)

        let allRange = NSRange(location: 0, length: attText.length)
        attText.addAttribute(.font, value: App.Font.caption, range: allRange)
        attText.addAttribute(.foregroundColor, value: App.Color.steel, range: allRange)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = textAlignment
        attText.addAttribute(.paragraphStyle, value: paragraphStyle, range: allRange)

        return attText
    }

    private func attText(_ string: String) -> NSMutableAttributedString {
        let attText = NSMutableAttributedString(string: string)

        let allRange = NSRange(location: 0, length: attText.length)
        attText.addAttribute(.font, value: App.Font.caption, range: allRange)
        attText.addAttribute(.foregroundColor, value: UIColor.black, range: allRange)

        return attText
    }

    private func updateLikeDislikeState() {
        likesImageNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(
            comment.getVote() == .liked ? App.Color.azure : App.Color.coolGrey
        )
        likesImageNode.setNeedsDisplay()
        likesNode.attributedText = attDetailText("\(comment.likesQuantity)")

        dislikesImageNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(
            comment.getVote() == .disliked ? App.Color.azure : App.Color.coolGrey
        )
        dislikesImageNode.setNeedsDisplay()
        dislikesNode.attributedText = attDetailText("\(comment.dislikesQuantity)")
    }

}
