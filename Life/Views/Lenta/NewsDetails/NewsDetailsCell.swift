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
         didLikeNews: @escaping (() -> Void),
         didTapImage: @escaping ((URL, [URL]) -> Void)) {
        self.news = news

        super.init()

        backgroundColor = .clear

        headerNode = NewsHeaderNode(
            news: news,
            didTapClose: didTapClose,
            didTapImage: { (selectedImage, imageStringURLs) in
                guard let url = URL(string: selectedImage) else { return }
                let urls = imageStringURLs.flatMap { URL(string: $0) }
                didTapImage(url, urls)
            }
        )
        addSubnode(headerNode)

        bodyNode = NewsBodyNode(
            news: news,
            needReloadOnWebViewLoad: needReloadOnWebViewLoad,
            webViewHeight: webViewHeight,
            didLoadWebView: didLoadWebView
        )
        bodyNode.didLikeNews = didLikeNews
        bodyNode.didTapImage = didTapImage
        addSubnode(bodyNode)
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let stackSpec = ASStackLayoutSpec.vertical()
        stackSpec.children = [headerNode, bodyNode]
        return stackSpec
    }

}
