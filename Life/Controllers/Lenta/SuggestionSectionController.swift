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
    private let commentToolbar = NSString(string: "commentToolbar")

    var onUnathorizedError: (() -> Void)?
    private(set) var didTapClose: (() -> Void)
    private(set) var didTapImage: ((URL, [URL]) -> Void)

    init(viewModel: SuggestionItemViewModel,
         didTapClose: @escaping (() -> Void),
         didTapImage:  @escaping ((URL, [URL]) -> Void)) {
        self.viewModel = viewModel
        self.didTapClose = didTapClose
        self.didTapImage = didTapImage

        super.init()
    }

    private func updateContents() {
        if let viewModel = viewModel {
            var items = [ListDiffable]()

            items.append(viewModel)

            let commentsViewModels = viewModel.suggestion.comments.map { CommentViewModel(comment: $0) }
            items.append(contentsOf: commentsViewModels as [ListDiffable])

            items.append(commentToolbar)

            set(items: items, animated: false, completion: nil)
        }
    }

    override func didUpdate(to object: Any) {
        viewModel = object as? SuggestionItemViewModel

        updateContents()
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
    private func scrollToBottom() {
        if let vc = self.viewController as? SuggestionViewController {
            vc.node.scrollToItem(
                at: IndexPath(item: self.items.count - 1, section: 0),
                at: .bottom,
                animated: false
            )
        }
    }

    private func commentCell() -> () -> ASCellNode {
        return {
            let cell = CommentToolbar()
            cell.didTapAdd = { text in
                guard !text.isEmpty else { return }
                self.viewModel?.addCommentToSuggestion(
                    commentText: text,
                    completion: { _ in
                        print("Added comment ...")

                        self.updateContents()
                        self.scrollToBottom()
                })
            }
            cell.didChange = {
                self.scrollToBottom()
            }
            return cell
        }
    }

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
                cell.didLikeComment = { vote in
                    self.viewModel?.likeComment(
                        id: object.comment.id,
                        voteType: vote,
                        completion: { _ in
                            print("User did like comment ...")
                    })
                }
                return cell
            }
        } else if items[index] is String {
            return commentCell()
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
                },
                didLikeSuggestion: { vote in
                    viewModel.likeSuggestion(vote: vote, completion: { _ in
                        print("User liked suggestion")
                    })
                },
                didTapImage: self.didTapImage
            )
            return cell
        }
    }

    func beginBatchFetch(with context: ASBatchContext) {
        DispatchQueue.main.async {
            self.viewModel?.getSuggestion(completion: { [weak self] (error) in
                guard let `self` = self,
                    let viewModel = self.viewModel else { return }

                if let moyaError = error as? MoyaError,
                    moyaError.response?.statusCode == 401,
                    let onUnathorizedError = self.onUnathorizedError {
                    onUnathorizedError()
                }

                var items = [ListDiffable]()

                items.append(viewModel)

                let commentsViewModels = viewModel.suggestion.comments.map { CommentViewModel(comment: $0) }
                items.append(contentsOf: commentsViewModels as [ListDiffable])

                items.append(self.commentToolbar)

                self.set(items: items, animated: false, completion: {
                    self.collectionContext?.performBatch(animated: true, updates: { (context) in
                        context.reload(in: self, at: IndexSet.init(integer: 0))
                    }, completion: { (_) in
                        context.completeBatchFetching(true)
                    })
                })
            })
        }
    }

    func shouldBatchFetch() -> Bool {
        return viewModel?.canLoadMore ?? false
    }
}

extension SuggestionSectionController: RefreshingSectionControllerType {
    func refreshContent(with completion: (() -> Void)?) {
        if let completion = completion {
            completion()
        }
    }
}
