//
//  SuggestionSectionController.swift
//  Life
//
//  Created by Shyngys Kassymov on 23.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import IGListKit
import Moya

class SuggestionSectionController: ASCollectionSectionController {
    private(set) weak var viewModel: SuggestionItemViewModel?

    var onUnathorizedError: (() -> Void)?
    private(set) var didTapClose: (() -> Void)

    init(viewModel: SuggestionItemViewModel, didTapClose: @escaping (() -> Void)) {
        self.viewModel = viewModel
        self.didTapClose = didTapClose

        super.init()
    }

    override func didUpdate(to object: Any) {
        viewModel = object as? SuggestionItemViewModel

        if let viewModel = viewModel {
            var items = [ListDiffable]()

            items.append(viewModel)

            let commentsViewModels = viewModel.suggestion.comments.map { CommentViewModel(comment: $0) }
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

extension SuggestionSectionController: ASSectionController {
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
            let cell = SuggestionDetailsCell(
                suggestion: viewModel.suggestion,
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

extension SuggestionSectionController: RefreshingSectionControllerType {
    func refreshContent(with completion: (() -> Void)?) {
        if let completion = completion {
            completion()
        }
    }
}
