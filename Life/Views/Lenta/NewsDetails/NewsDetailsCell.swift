//
//  NewsDetailsCell.swift
//  Life
//
//  Created by Shyngys Kassymov on 22.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class NewsDetailsCell: ASCellNode {

    private(set) var headerNode: NewsHeaderNode!
    private(set) var bodyNode: NewsBodyNode!

    private(set) var news: News

    init(news: News,
         didTapClose: @escaping (() -> Void),
         needReloadOnWebViewLoad: Bool,
         webViewHeight: CGFloat,
         didLoadWebView: @escaping ((CGFloat) -> Void),
         didLikeNews: @escaping (() -> Void)) {
        self.news = news

        super.init()

        backgroundColor = .clear

        headerNode = NewsHeaderNode(news: news, didTapClose: didTapClose)
        addSubnode(headerNode)

        bodyNode = NewsBodyNode(
            news: news,
            needReloadOnWebViewLoad: needReloadOnWebViewLoad,
            webViewHeight: webViewHeight,
            didLoadWebView: didLoadWebView
        )
        bodyNode.didLikeNews = didLikeNews
        addSubnode(bodyNode)
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let stackSpec = ASStackLayoutSpec.vertical()
        stackSpec.children = [headerNode, bodyNode]
        return stackSpec
    }

}
