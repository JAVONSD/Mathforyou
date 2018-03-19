//
//  TodayHeader.swift
//  Life
//
//  Created by Shyngys Kassymov on 20.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import DateToolsSwift

class TodayHeader: ASCellNode {

    private(set) var dateNode: ASTextNode!
    private(set) var todayNode: ASTextNode!

    init(date: Date) {
        super.init()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE d MMMM"

        dateNode = ASTextNode()
        dateNode.attributedText = attDate(dateFormatter.string(from: date).uppercased())
        addSubnode(dateNode)

        todayNode = ASTextNode()
        todayNode.attributedText = attToday(NSLocalizedString("today", comment: ""))
        addSubnode(todayNode)
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let stackSpec = ASStackLayoutSpec.vertical()
        stackSpec.children = [dateNode, todayNode]
        stackSpec.spacing = 2

        let insetSpec = ASInsetLayoutSpec(
            insets: .init(
                top: App.Layout.itemSpacingMedium -
                    App.Layout.itemSpacingSmall / 2,
                left: App.Layout.itemSpacingMedium,
                bottom: App.Layout.itemSpacingMedium,
                right: App.Layout.itemSpacingMedium
            ),
            child: stackSpec)

        return insetSpec
    }

    // MARK: - Methods

    private func attDate(_ string: String) -> NSMutableAttributedString {
        let attText = NSMutableAttributedString(string: string)

        let allRange = NSRange(location: 0, length: attText.length)
        attText.addAttribute(.font, value: App.Font.label, range: allRange)
        attText.addAttribute(.foregroundColor, value: App.Color.slateGrey, range: allRange)

        return attText
    }

    private func attToday(_ string: String) -> NSMutableAttributedString {
        let attText = NSMutableAttributedString(string: string)

        let allRange = NSRange(location: 0, length: attText.length)
        attText.addAttribute(.font, value: App.Font.titleSmall, range: allRange)
        attText.addAttribute(.foregroundColor, value: UIColor.black, range: allRange)

        return attText
    }

}
