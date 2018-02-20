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

    init(viewModel: TopQuestionsViewModel) {
        self.viewModel = viewModel

        super.init()
    }

    override func didUpdate(to object: Any) {
        self.viewModel = object as? TopQuestionsViewModel

        guard let viewModel = self.viewModel else { return }

        var items = [ListDiffable]()
        items.append(DateCell())
        if !viewModel.minimized {
            items.append(contentsOf: viewModel.questions as [ListDiffable])
        }

        set(items: items, animated: false, completion: nil)
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

extension TopQuestionsSectionController: ASSectionController {
    func nodeBlockForItem(at index: Int) -> ASCellNodeBlock {
        guard index < items.count,
            let viewModel = self.viewModel else {
                return {
                    return ASCellNode()
                }
        }

        return {
            let corners = viewModel.minimized
                ? UIRectCorner.allCorners
                : [UIRectCorner.topLeft, UIRectCorner.topRight]
            let config = DashboardGalleryCell.Config(
                image: "",
                title: NSLocalizedString("questions", comment: ""),
                corners: corners,
                images: ["", "", "", "", "", ""],
                didTapOnImage: { index in
                    print("Selected image at index - \(index)")
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
                items.append(contentsOf: viewModel.questions as [ListDiffable])
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
        if let completion = completion {
            completion()
        }
    }
}
