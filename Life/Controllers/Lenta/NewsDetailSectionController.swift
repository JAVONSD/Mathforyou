//
//  NewsDetailSectionController.swift
//  Life
//
//  Created by Shyngys Kassymov on 22.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import IGListKit
import Moya

class NewsDetailSectionController: ASCollectionSectionController {
    private(set) weak var viewModel: NewsItemViewModel?

    var onUnathorizedError: (() -> Void)?
    private(set) var didTapClose: (() -> Void)

    init(viewModel: NewsItemViewModel, didTapClose: @escaping (() -> Void)) {
        self.viewModel = viewModel
        self.didTapClose = didTapClose

        super.init()
    }

    override func didUpdate(to object: Any) {
        viewModel = object as? NewsItemViewModel

        if let viewModel = viewModel {
            var items = [ListDiffable]()

            items.append(viewModel)

            let commentsViewModels = viewModel.news.comments.map { CommentViewModel(comment: $0) }
            items.append(contentsOf: commentsViewModels as [ListDiffable])

            set(items: items, animated: false, completion: nil)
        }
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        return ASIGListSectionControllerMethods.cellForItem(at: index, sectionController: self)
    }

    override func sizeForItem(at index: Int) -> CGSize {
        return ASIGListSectionControllerMethods.sizeForItem(at: index)
    }

    override func didSelectItem(at index: Int) {
        print("Selected item at index - \(index)")
    }
}

extension NewsDetailSectionController: ASSectionController {
    func nodeBlockForItem(at index: Int) -> ASCellNodeBlock {
        guard index < items.count,
            let viewModel = self.viewModel else {
                return {
                    return ASCellNode()
                }
        }

        if let object = items[index] as? CommentViewModel {
            return {
                let cell = NewsCommentCell(comment: object.comment)
                return cell
            }
        }

        return {
            let cell = NewsDetailsCell(
                news: viewModel.news,
                didTapClose: self.didTapClose,
                needReloadOnWebViewLoad: viewModel.needReloadOnWebViewLoad,
                webViewHeight: viewModel.calculatedWebViewHeight,
                didLoadWebView: { height in
                    viewModel.needReloadOnWebViewLoad = false
                    viewModel.calculatedWebViewHeight = height
                }
            )
            return cell
        }
    }

    func beginBatchFetch(with context: ASBatchContext) {
        context.completeBatchFetching(true)
    }

    func shouldBatchFetch() -> Bool {
        return false
    }
}

extension NewsDetailSectionController: RefreshingSectionControllerType {
    func refreshContent(with completion: (() -> Void)?) {
        if let completion = completion {
            completion()
        }
    }
}
