//
//  NewsSectionController.swift
//  Life
//
//  Created by Shyngys Kassymov on 16.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import IGListKit
import Moya

protocol RefreshingSectionControllerType {
    func refreshContent(with completion: (() -> Void)?)
}

class NewsSectionController: ASCollectionSectionController {
    private(set) weak var viewModel: LentaViewModel?

    var onUnathorizedError: (() -> Void)?

    init(viewModel: LentaViewModel) {
        self.viewModel = viewModel

        super.init()

        supplementaryViewSource = self
    }

    override func didUpdate(to object: Any) {
        viewModel = object as? LentaViewModel
        let items = (viewModel?.items ?? []) as [ListDiffable]

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

extension NewsSectionController: ASSectionController {
    func nodeBlockForItem(at index: Int) -> ASCellNodeBlock {
        guard index < items.count,
            let viewModel = self.viewModel else {
            return {
                return ASCellNode()
            }
        }

        if let object = items[index] as? LentaItemViewModel {
            return {
                let cell = NewsCell(viewModel: object)
                return cell
            }
        }

        return {
            let cell = LentaOverviewCell(viewModel: viewModel)
            return cell
        }
    }

    func beginBatchFetch(with context: ASBatchContext) {
        DispatchQueue.main.async {
            self.viewModel?.fetchNextPage({ [weak self] (error) in
                guard let `self` = self,
                    let viewModel = self.viewModel else { return }

                if let moyaError = error as? MoyaError,
                    moyaError.response?.statusCode == 401,
                    let onUnathorizedError = self.onUnathorizedError {
                    onUnathorizedError()
                }

                self.set(items: viewModel.items, animated: false, completion: {
                    context.completeBatchFetching(true)
                })
            })
        }
    }

    func shouldBatchFetch() -> Bool {
        return viewModel?.canLoadMore ?? false
    }

}

extension NewsSectionController: RefreshingSectionControllerType {
    func refreshContent(with completion: (() -> Void)?) {
        viewModel?.reload { [weak self] (error) in
            guard let `self` = self,
                let viewModel = self.viewModel else { return }

            if let moyaError = error as? MoyaError,
                moyaError.response?.statusCode == 401,
                let onUnathorizedError = self.onUnathorizedError {
                onUnathorizedError()
            }
            self.set(items: viewModel.items, animated: true, completion: completion)
        }
    }
}

extension NewsSectionController: ASSupplementaryNodeSource {
    func nodeBlockForSupplementaryElement(ofKind elementKind: String, at index: Int) -> ASCellNodeBlock {
        return {
            guard let viewModel = self.viewModel else {
                return ASCellNode()
            }
            return LentaOverviewCell(viewModel: viewModel)
        }
    }

    func sizeRangeForSupplementaryElement(ofKind elementKind: String, at index: Int) -> ASSizeRange {
        if elementKind == UICollectionElementKindSectionHeader {
            return ASSizeRangeUnconstrained
        } else {
            return ASSizeRangeZero
        }
    }
}

extension NewsSectionController: ListSupplementaryViewSource {
    func supportedElementKinds() -> [String] {
        return [UICollectionElementKindSectionHeader]
    }

    func viewForSupplementaryElement(ofKind elementKind: String, at index: Int) -> UICollectionReusableView {
        return ASIGListSupplementaryViewSourceMethods
            .viewForSupplementaryElement(
                ofKind: elementKind,
                at: index,
                sectionController: self)
    }

    func sizeForSupplementaryView(ofKind elementKind: String, at index: Int) -> CGSize {
        return ASIGListSupplementaryViewSourceMethods.sizeForSupplementaryView(ofKind: elementKind, at: index)
    }

}
