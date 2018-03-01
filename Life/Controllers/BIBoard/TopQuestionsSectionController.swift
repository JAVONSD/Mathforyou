//
//  TopQuestionsSectionController.swift
//  Life
//
//  Created by Shyngys Kassymov on 20.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import IGListKit
import Moya

class TopQuestionsSectionController: ASCollectionSectionController {
    private(set) weak var viewModel: TopQuestionsViewModel?

    var onUnathorizedError: (() -> Void)?
    var didTapTop7: ((String) -> Void)?

    init(viewModel: TopQuestionsViewModel) {
        self.viewModel = viewModel

        super.init()
    }

    override func didUpdate(to object: Any) {
        self.viewModel = object as? TopQuestionsViewModel
        updateContents()
    }

    private func updateContents() {
        var items = [ListDiffable]()
        items.append(DateCell())

        set(items: items, animated: false, completion: nil)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        return ASIGListSectionControllerMethods.cellForItem(at: index, sectionController: self)
    }

    override func sizeForItem(at index: Int) -> CGSize {
        return ASIGListSectionControllerMethods.sizeForItem(at: index)
    }

    override func didSelectItem(at index: Int) {
    }
}

extension TopQuestionsSectionController: ASSectionController {
    func nodeBlockForItem(at index: Int) -> ASCellNodeBlock {
        guard index < items.count,
            let viewModel = self.viewModel else {
                return {
                    return ASCellNode()
                }
        }

        return {
            let images = viewModel.questions.questions.map { $0.question.authorCode }

            let corners = viewModel.minimized
                ? UIRectCorner.allCorners
                : [UIRectCorner.topLeft, UIRectCorner.topRight]
            let config = DashboardGalleryCell.Config(
                image: "",
                title: NSLocalizedString("questions", comment: ""),
                corners: corners,
                images: images,
                didTapOnImage: { index in
                    print("Tapped image at index - \(index)")
                    if let didTapTop7 = self.didTapTop7 {
                        didTapTop7("")
                    }
                })

            return DashboardGalleryCell(config: config)
        }
    }

    func beginBatchFetch(with context: ASBatchContext) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self,
                let viewModel = self.viewModel else { return }

            var items = [ListDiffable]()
            if self.items.isEmpty {
                items.insert(DateCell(), at: 0)
            }
            if !viewModel.minimized {
                items.append(contentsOf: viewModel.questions.questions as [ListDiffable])
            }

            self.set(items: items, animated: false, completion: {
                context.completeBatchFetching(true)
            })
        }
    }

    func shouldBatchFetch() -> Bool {
        return false
    }

}

extension TopQuestionsSectionController: RefreshingSectionControllerType {
    func refreshContent(with completion: (() -> Void)?) {
        viewModel?.questions.getQuestions { [weak self] error in
            if let moyaError = error as? MoyaError,
                moyaError.response?.statusCode == 401,
                let onUnathorizedError = self?.onUnathorizedError {
                onUnathorizedError()
            }
            self?.updateContents()
            if let completion = completion {
                completion()
            }
        }
    }
}
