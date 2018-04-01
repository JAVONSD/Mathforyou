//
//  SuggestionDetailsCell.swift
//  Life
//
//  Created by Shyngys Kassymov on 22.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class SuggestionDetailsCell: ASCellNode {

    private(set) var headerNode: SuggestionHeaderNode!
    private(set) var bodyNode: SuggestionBodyNode!

    private(set) var suggestion: Suggestion

    init(suggestion: Suggestion,
         didTapClose: @escaping (() -> Void),
         needReloadOnWebViewLoad: Bool,
         webViewHeight: CGFloat,
         didLoadWebView: @escaping ((CGFloat) -> Void),
         didLikeSuggestion: @escaping ((UserVote) -> Void),
         didTapImage: @escaping ((URL, [URL]) -> Void)) {
        self.suggestion = suggestion

        super.init()

        backgroundColor = .clear

        headerNode = SuggestionHeaderNode(
            suggestion: suggestion,
            didTapClose: didTapClose,
            didTapImage: { (selectedImage, imageStringURLs) in
                guard let url = URL(string: selectedImage) else { return }
                let urls = imageStringURLs.flatMap { URL(string: $0) }
                didTapImage(url, urls)
            }
        )
        addSubnode(headerNode)

        bodyNode = SuggestionBodyNode(
            suggestion: suggestion,
            needReloadOnWebViewLoad: needReloadOnWebViewLoad,
            webViewHeight: webViewHeight,
            didLoadWebView: didLoadWebView
        )
        bodyNode.didLikeSuggestion = didLikeSuggestion
        bodyNode.didTapImage = didTapImage
        addSubnode(bodyNode)
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let stackSpec = ASStackLayoutSpec.vertical()
        stackSpec.children = [headerNode, bodyNode]
        return stackSpec
    }

}
