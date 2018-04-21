//
//  SuggestionsSectionController.swift
//  Life
//
//  Created by Shyngys Kassymov on 19.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import IGListKit
import Moya
import RxSwift

class SuggestionsSectionController: ASCollectionSectionController {
    private(set) weak var viewModel: SuggestionsViewModel?

    var onUnathorizedError: (() -> Void)?
    var didTapAtSuggestion: ((String) -> Void)?
    var didTapAddSuggestion: (() -> Void)?
    var didTapViewAll: (() -> Void)?

    init(viewModel: SuggestionsViewModel) {
        self.viewModel = viewModel

        super.init()
    }

    override func didUpdate(to object: Any) {
        self.viewModel = object as? SuggestionsViewModel
        updateContents()
    }

    public func updateContents() {
        guard let viewModel = self.viewModel else {
            return
        }

        var items = [ListDiffable]()
        items.append(DateCell())
        if !viewModel.minimized {
            items.append(contentsOf: Array(viewModel.suggestions.prefix(5)) as [ListDiffable])
        }
        if !viewModel.minimized && viewModel.suggestions.count > 5 {
            items.append(NSString(string: "ViewMoreCell"))
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
        guard let viewModel = viewModel else { return }

        if index == 0 {
            didTapViewAll?()
        } else if let didTapAtSuggestion = didTapAtSuggestion, index > 0 && index < 5 {
            didTapAtSuggestion(Array(viewModel.suggestions.prefix(5))[index - 1].suggestion.id)
        } else if viewModel.suggestions.count > 5 && index == self.items.count - 1 {
            if let didTapViewAll = didTapViewAll {
                didTapViewAll()
            }
        }
    }

    // MARK: - Methods

    private func toggle() {
        if let viewModel = self.viewModel,
            !viewModel.suggestions.isEmpty {
            viewModel.minimized = !viewModel.minimized
            updateContents()
        }
    }
}

extension SuggestionsSectionController: ASSectionController {
    func nodeBlockForItem(at index: Int) -> ASCellNodeBlock {
        guard index < items.count else {
            return {
                return ASCellNode()
            }
        }

        if let suggestion = items[index] as? SuggestionItemViewModel {
            return {
                let separatorInset = index == 1
                    ? ItemCell.SeparatorInset(
                        left: App.Layout.itemSpacingMedium,
                        right: 0)
                    : ItemCell.SeparatorInset(
                        left: App.Layout.itemSpacingMedium,
                        right: App.Layout.itemSpacingMedium)
                let bottomInset: CGFloat = index == self.items.count - 1
                    ? App.Layout.itemSpacingMedium
                    : App.Layout.itemSpacingSmall
                let corners: UIRectCorner = index == self.items.count - 1
                    ? [UIRectCorner.bottomLeft, UIRectCorner.bottomRight]
                    : []
                return ItemCell(
                    title: suggestion.suggestion.title,
                    subtitle: suggestion.suggestion.createDate.prettyDateOrTimeAgoString(),
                    separatorLeftRightInset: separatorInset,
                    bottomInset: bottomInset,
                    separatorHidden: false,
                    corners: corners
                )
            }
        }

        return {
            if index != 0 {
                let corners: UIRectCorner = [UIRectCorner.bottomLeft, UIRectCorner.bottomRight]
                return LabelNode(
                    text: NSLocalizedString("view_all", comment: ""),
                    corners: corners
                )
            }
            return self.dashboardCell()
        }
    }

    private func dashboardCell() -> ASCellNode {
        guard let viewModel = self.viewModel else {
            return ASCellNode()
        }

        let corners = viewModel.minimized
            ? UIRectCorner.allCorners
            : [UIRectCorner.topLeft, UIRectCorner.topRight]
        let config = DashboardCell.Config(
            image: "",
            title: NSLocalizedString("suggestions", comment: ""),
            itemColor: .black,
            item1Count: viewModel.suggestions.count,
            item1Title: NSLocalizedString("total_count_short", comment: ""),
            item2Count: viewModel.suggestions.count,
            item2Title: NSLocalizedString("total_count_short", comment: ""),
            item3Count: viewModel.popularSuggestions.count,
            item3Title: NSLocalizedString("popular_count_short", comment: ""),
            showAddButton: true,
            corners: corners,
            minimized: viewModel.minimized,
            didTapAddButton: {
        })

        let cell = DashboardCell(config: config)
        cell.didTapToggle = { [weak self] in
            self?.toggle()
        }
        cell.didTapAdd = {
            if let didTapAddSuggestion = self.didTapAddSuggestion {
                didTapAddSuggestion()
            }
        }
        return cell
    }

    func beginBatchFetch(with context: ASBatchContext) {
        context.completeBatchFetching(true)
    }

    func shouldBatchFetch() -> Bool {
        return false
    }
}

extension SuggestionsSectionController: RefreshingSectionControllerType {
    func refreshContent(with completion: (() -> Void)?) {
        viewModel?.getSuggestions { [weak self] error in
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
        viewModel?.getPopularSuggestions { [weak self] error in
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
