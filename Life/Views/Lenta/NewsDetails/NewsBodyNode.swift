//
//  NewsBodyNode.swift
//  Life
//
//  Created by Shyngys Kassymov on 22.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import Hue
import Kingfisher
import NVActivityIndicatorView
import WebKit

class NewsBodyNode: ASDisplayNode {

    private let imageScheme = "openimage://"

    private(set) var authorImageNode: ASNetworkImageNode!
    private(set) var authorNameNode: ASTextNode!
    private(set) var dateNode: ASTextNode!

    private(set) var separator1Node: ASDisplayNode!

    private(set) var webView: WebView!
    private(set) var webViewNode: ASDisplayNode!

    private(set) lazy var spinner = NVActivityIndicatorView(
        frame: .init(x: 0, y: 0, width: 24, height: 24),
        type: .circleStrokeSpin,
        color: App.Color.azure,
        padding: 0)
    private(set) var spinnerNode: ASDisplayNode!

    private(set) var likesImageNode: ASImageNode!
    private(set) var likesNode: ASTextNode!

    private(set) var viewsImageNode: ASImageNode!
    private(set) var viewsNode: ASTextNode!

    private(set) var separator2Node: ASDisplayNode!

    private(set) var commentsNode: ASTextNode!
    private(set) var commentsCountNode: ASTextNode!

    private(set) var news: News
    private(set) var needReloadOnWebViewLoad: Bool
    private(set) var didLoadWebView: ((CGFloat) -> Void)

    var didLikeNews: (() -> Void)?
    var didTapImage: ((URL, [URL]) -> Void)?

    private(set) var webViewHeight: CGFloat = 0

    init(news: News,
         needReloadOnWebViewLoad: Bool,
         webViewHeight: CGFloat,
         didLoadWebView: @escaping ((CGFloat) -> Void)) {
        self.news = news
        self.needReloadOnWebViewLoad = needReloadOnWebViewLoad
        self.webViewHeight = webViewHeight
        self.didLoadWebView = didLoadWebView

        super.init()

        if !news.isPublishedAsGroup {
            authorImageNode = ASNetworkImageNode()
            authorImageNode.cornerRadius = App.Layout.cornerRadiusSmall
            authorImageNode.image = #imageLiteral(resourceName: "ic-user")
            addSubnode(authorImageNode)
        }

        authorNameNode = ASTextNode()
        authorNameNode.attributedText = attAuthorName(news.authorName)
        addSubnode(authorNameNode)

        dateNode = ASTextNode()
        dateNode.attributedText = attDateText(news.createDate.prettyDateString(format: "dd.MM.yyyy HH:mm"))
        addSubnode(dateNode)

        separator1Node = ASDisplayNode()
        separator1Node.backgroundColor = App.Color.coolGrey
        addSubnode(separator1Node)

        addWebNode()
        addLikesViews()

        separator2Node = ASDisplayNode()
        separator2Node.backgroundColor = App.Color.coolGrey
        addSubnode(separator2Node)

        commentsNode = ASTextNode()
        commentsNode.attributedText = attCommentsText(NSLocalizedString("comments", comment: ""))
        addSubnode(commentsNode)

        commentsCountNode = ASTextNode()
        commentsCountNode.attributedText = attDetailText("\(news.comments.count)")
        addSubnode(commentsCountNode)
    }

    private func addWebNode() {
        webViewNode = ASDisplayNode(viewBlock: { () -> UIView in
            let source = self.changeImagesScheme()
            let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)

            let controller = WKUserContentController()
            controller.addUserScript(script)

            let configuration = WKWebViewConfiguration()
            configuration.userContentController = controller

            self.webView = WebView(
                frame: .init(
                    x: 0,
                    y: 0,
                    width: UIScreen.main.bounds.size.width - 2 * App.Layout.sideOffset,
                    height: 0
                ),
                configuration: configuration
            )
            self.webView.navigationDelegate = self
            self.webView.loadHTMLString(
                self.news.text.html(),
                baseURL: URL(fileURLWithPath: Bundle.main.path(forResource: "news", ofType: "css")!)
            )
            self.webView.scrollView.isScrollEnabled = false
            return self.webView
        })
        webViewNode.style.preferredSize = CGSize(
            width: UIScreen.main.bounds.size.width - 2 * App.Layout.sideOffset,
            height: webViewHeight
        )
        webViewNode.isHidden = true
        addSubnode(webViewNode)

        spinnerNode = ASDisplayNode(viewBlock: { () -> UIView in
            self.spinner.startAnimating()
            return self.spinner
        })
        spinnerNode.backgroundColor = .clear
        spinnerNode.style.preferredSize = CGSize(width: 24, height: 24)
        addSubnode(spinnerNode)
    }

    private func addLikesViews() {
        likesImageNode = ASImageNode()
        likesImageNode.addTarget(
            self,
            action: #selector(handleLikeButton),
            forControlEvents: .touchUpInside
        )
        likesImageNode.image = #imageLiteral(resourceName: "like-inactive")
        likesImageNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(
            self.news.isLikedByMe ? App.Color.azure : App.Color.coolGrey
        )
        addSubnode(likesImageNode)

        likesNode = ASTextNode()
        likesNode.attributedText = attDetailText("\(news.likesQuantity)")
        addSubnode(likesNode)

        viewsImageNode = ASImageNode()
        viewsImageNode.image = #imageLiteral(resourceName: "view")
        viewsImageNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(
            App.Color.coolGrey
        )
        addSubnode(viewsImageNode)

        viewsNode = ASTextNode()
        viewsNode.attributedText = attDetailText("\(news.viewsQuantity)")
        addSubnode(viewsNode)
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        separator1Node.style.preferredSize = CGSize(
            width: constrainedSize.max.width - 2 * App.Layout.sideOffset,
            height: 0.5
        )
        let sep1Spec = ASInsetLayoutSpec(insets: .init(
            top: 0,
            left: App.Layout.sideOffset,
            bottom: 0,
            right: App.Layout.sideOffset), child: separator1Node)

        separator2Node.style.preferredSize = CGSize(
            width: constrainedSize.max.width - 2 * App.Layout.sideOffset,
            height: 0.5
        )
        let sep2Spec = ASInsetLayoutSpec(insets: .init(
            top: 0,
            left: App.Layout.sideOffset,
            bottom: 0,
            right: App.Layout.sideOffset), child: separator2Node)

        let stackSpec = ASStackLayoutSpec.vertical()
        stackSpec.children = [
            authorSpec(),
            sep1Spec,
            webSpec(),
            likesViewsSpec(),
            sep2Spec,
            commentsSpec()
        ]

        return stackSpec
    }

    private func authorSpec() -> ASLayoutSpec {
        if !news.isPublishedAsGroup {
            authorImageNode.style.preferredSize = CGSize(width: 40, height: 40)
        }

        let nameDateSpec = ASStackLayoutSpec.vertical()
        nameDateSpec.children = [authorNameNode, dateNode]
        nameDateSpec.spacing = App.Layout.itemSpacingSmall / 2

        let stackSpec = ASStackLayoutSpec.horizontal()
        if !news.isPublishedAsGroup {
            stackSpec.children = [authorImageNode, nameDateSpec]
        } else {
            stackSpec.children = [nameDateSpec]
        }
        stackSpec.spacing = App.Layout.itemSpacingMedium
        stackSpec.alignItems = .center

        return ASInsetLayoutSpec(insets: .init(
            top: App.Layout.itemSpacingSmall,
            left: App.Layout.sideOffset,
            bottom: App.Layout.itemSpacingMedium,
            right: App.Layout.sideOffset), child: stackSpec)
    }

    private func webSpec() -> ASLayoutSpec {
        let webSpec = ASInsetLayoutSpec(insets: .init(
            top: App.Layout.sideOffset,
            left: App.Layout.sideOffset,
            bottom:0,
            right: App.Layout.sideOffset), child: webViewNode)

        let spinnerSpec = ASStackLayoutSpec.vertical()
        spinnerSpec.children = [spinnerNode]
        spinnerSpec.alignItems = .center
        spinnerSpec.justifyContent = .center

        return ASOverlayLayoutSpec(child: webSpec, overlay: spinnerSpec)
    }

    private func likesViewsSpec() -> ASLayoutSpec {
        let likesSpec = ASStackLayoutSpec.horizontal()
        likesSpec.children = [likesImageNode, likesNode]
        likesSpec.alignItems = .center
        likesSpec.spacing = App.Layout.itemSpacingSmall

        let viewsSpec = ASStackLayoutSpec.horizontal()
        viewsSpec.children = [viewsImageNode, viewsNode]
        viewsSpec.alignItems = .center
        viewsSpec.spacing = App.Layout.itemSpacingSmall

        let stackSpec = ASStackLayoutSpec.horizontal()
        stackSpec.children = [likesSpec, viewsSpec]
        stackSpec.alignItems = .center
        stackSpec.justifyContent = .spaceBetween
        stackSpec.spacing = App.Layout.itemSpacingMedium

        return ASInsetLayoutSpec(insets: .init(
            top: App.Layout.itemSpacingMedium,
            left: App.Layout.sideOffset,
            bottom: App.Layout.itemSpacingMedium,
            right: App.Layout.sideOffset), child: stackSpec)
    }

    private func commentsSpec() -> ASLayoutSpec {
        let stackSpec = ASStackLayoutSpec.horizontal()
        stackSpec.children = [commentsNode, commentsCountNode]
        stackSpec.alignItems = .center
        stackSpec.spacing = App.Layout.itemSpacingSmall

        return ASInsetLayoutSpec(insets: .init(
            top: App.Layout.itemSpacingMedium,
            left: App.Layout.sideOffset,
            bottom: App.Layout.sideOffset,
            right: App.Layout.sideOffset), child: stackSpec)
    }

    override func didLoad() {
        super.didLoad()

        guard !news.isPublishedAsGroup else { return }

        ImageDownloader.download(
            image: "",
            employeeCode: news.authorCode,
            placeholderImage: #imageLiteral(resourceName: "ic-user"),
            size: CGSize(width: 40, height: 40)) { (image) in
                self.authorImageNode.image = image
        }
    }

    // MARK: - Actions

    @objc
    private func handleLikeButton() {
        news.isLikedByMe = !news.isLikedByMe
        news.likesQuantity += news.isLikedByMe ? 1 : -1

        likesImageNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(
            self.news.isLikedByMe ? App.Color.azure : App.Color.coolGrey
        )
        likesImageNode.setNeedsDisplay()
        likesNode.attributedText = attDetailText("\(news.likesQuantity)")

        if let didLikeNews = didLikeNews {
            didLikeNews()
        }
    }

    // MARK: - Methods

    private func attAuthorName(_ string: String) -> NSMutableAttributedString {
        let attText = NSMutableAttributedString(string: string)

        let allRange = NSRange(location: 0, length: attText.length)
        attText.addAttribute(.font, value: App.Font.bodyAlts, range: allRange)
        attText.addAttribute(.foregroundColor, value: UIColor.black, range: allRange)

        return attText
    }

    private func attDateText(_ string: String) -> NSMutableAttributedString {
        let attText = NSMutableAttributedString(string: string)

        let allRange = NSRange(location: 0, length: attText.length)
        attText.addAttribute(.font, value: App.Font.body, range: allRange)
        attText.addAttribute(.foregroundColor, value: App.Color.steel, range: allRange)

        return attText
    }

    private func attText(_ string: String) -> NSMutableAttributedString {
        let attText = NSMutableAttributedString(string: string)

        let allRange = NSRange(location: 0, length: attText.length)
        attText.addAttribute(.font, value: App.Font.body, range: allRange)
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

    private func attCommentsText(_ string: String) -> NSMutableAttributedString {
        let attText = NSMutableAttributedString(string: string)

        let allRange = NSRange(location: 0, length: attText.length)
        attText.addAttribute(.font, value: App.Font.footnote, range: allRange)
        attText.addAttribute(.foregroundColor, value: App.Color.slateGrey, range: allRange)

        return attText
    }

}

extension NewsBodyNode: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        spinnerNode.isHidden = true
        webViewNode.isHidden = false

        guard needReloadOnWebViewLoad else {
            return
        }

        self.webView.evaluateJavaScript(
            """
            var B = document.body,
                H = document.documentElement,
                height;

            if (typeof document.height !== 'undefined') {
                height = document.height; // For webkit browsers
            } else {
                height = Math.max(
                    B.scrollHeight,
                    B.offsetHeight,
                    H.clientHeight,
                    H.scrollHeight,
                    H.offsetHeight
                );
            }
            height;
            """,
            completionHandler: { (height, _) in
                let height = height as? CGFloat ?? 0
                self.webViewHeight = height
                self.webViewNode.style.preferredSize = CGSize(
                    width: UIScreen.main.bounds.size.width - 2 * App.Layout.sideOffset,
                    height: height
                )

                self.spinnerNode.style.preferredSize = .zero
                self.spinnerNode.removeFromSupernode()

                self.setNeedsLayout()
                self.layoutIfNeeded()

                if height > 24 {
                    self.didLoadWebView(height)
                }
        })
    }

    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated {
            if let url = navigationAction.request.url,
                url.absoluteString.hasPrefix(imageScheme) {
                var urlPath = url.absoluteString
                urlPath.removeFirst(imageScheme.count + "https//".count)
                urlPath = "https://" + urlPath
                if let didTapImage = didTapImage,
                    let imageUrl = URL(string: urlPath) {
                    getAllImageURLs(in: webView, completion: { (allImages) in
                        didTapImage(imageUrl, allImages)
                    })
                }
            }
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }

    private func changeImagesScheme() -> String {
        let jsString =
        """
        var imgs = document.getElementsByTagName("img");
        for (var i = 0; i < imgs.length; i++) {
            var newImgs = '<a href="\(imageScheme)' + imgs[i].src + '">' + imgs[i].outerHTML + '</a>';
            imgs[i].outerHTML = newImgs;
        }
        """
        return jsString
    }

    private func getAllImageURLs(in webView: WKWebView, completion: @escaping (([URL]) -> Void)) {
        let jsString =
        """
        var imgs = document.getElementsByTagName("img");
        var imgURLs = [];
        for (var i = 0; i < imgs.length; i++) {
            imgURLs.push(imgs[i].src);
        }
        imgURLs
        """
        webView.evaluateJavaScript(jsString, completionHandler: { (imageURLs, _) in
            var urls = [URL]()
            if let imageURLs = imageURLs as? [String] {
                for imageURL in imageURLs {
                    if let url = URL(string: imageURL) {
                        urls.append(url)
                    }
                }
            }
            completion(urls)
        })
    }
}
