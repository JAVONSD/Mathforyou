//
//  CommentToolbar.swift
//  Life
//
//  Created by Shyngys Kassymov on 25.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import Material

class CommentToolbar: ASCellNode {

    private(set) var addButton: ASButtonNode!
    private(set) var textNode: ASEditableTextNode!

    var didTapAdd: ((String) -> Void)?
    var didChange: (() -> Void)?

    override init() {
        super.init()

        backgroundColor = UIColor(
            red: 254.0/255.0,
            green: 254.0/255.0,
            blue: 254.0/255.0,
            alpha: 0.8
        )

        shadowColor = App.Color.paleGreyTwo.cgColor
        shadowOffset = CGSize(width: 0, height: -0.5)
        shadowOpacity = 1
        shadowRadius = 0

        addButton = ASButtonNode()
        addButton.addTarget(
            self,
            action: #selector(handleAddButton),
            forControlEvents: .touchUpInside
        )
        addButton.borderColor = App.Color.coolGrey.cgColor
        addButton.borderWidth = 0.5
        addButton.cornerRadius = 16
        addButton.setImage(Icon.cm.add, for: .normal)
        addButton.imageNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(
            App.Color.azure
        )
        addButton.style.preferredSize = CGSize(width: 32, height: 32)
        addSubnode(addButton)

        textNode = ASEditableTextNode()
        textNode.backgroundColor = App.Color.paleGrey
        textNode.borderColor = App.Color.coolGrey.cgColor
        textNode.borderWidth = 0.5
        textNode.cornerRadius = 16
        textNode.delegate = self
        textNode.clipsToBounds = true
        textNode.textContainerInset = .init(top: 6, left: 16, bottom: 6, right: 16)
        addSubnode(textNode)
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let spacing = 32 + App.Layout.itemSpacingMedium * 2 + App.Layout.itemSpacingSmall
        textNode.style.minSize = CGSize(
            width: constrainedSize.max.width - spacing,
            height: 32
        )
        textNode.style.maxSize = CGSize(
            width: constrainedSize.max.width - spacing,
            height: UIScreen.main.bounds.size.height - 100
        )

        let textSpec = ASStackLayoutSpec.vertical()
        textSpec.children = [textNode]

        let stackSpec = ASStackLayoutSpec.horizontal()
        stackSpec.children = [addButton, textSpec]
        stackSpec.alignItems = .center
        stackSpec.spacing = App.Layout.itemSpacingSmall

        return ASInsetLayoutSpec(insets: .init(
            top: 12,
            left: App.Layout.itemSpacingMedium,
            bottom: 12,
            right: App.Layout.itemSpacingMedium), child: stackSpec)
    }

    override func didLoad() {
        super.didLoad()

        textNode.textView.font = App.Font.subhead
        textNode.textView.textColor = .black
    }

    // MARK: - Actions

    @objc
    private func handleAddButton() {
        if let didTapAdd = didTapAdd {
            didTapAdd(textNode.attributedText?.string ?? "")
        }

        textNode.attributedText = nil

        setNeedsLayout()
        layoutIfNeeded()

        if let didChange = didChange {
            didChange()
        }
    }

}

extension CommentToolbar: ASEditableTextNodeDelegate {
    func editableTextNodeDidUpdateText(_ editableTextNode: ASEditableTextNode) {
        setNeedsLayout()
        layoutIfNeeded()

        if let didChange = didChange {
            didChange()
        }
    }
}
