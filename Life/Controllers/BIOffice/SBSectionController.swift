//
//  SBSectionController.swift
//  Life
//
//  Created by Shyngys Kassymov on 20.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import IGListKit
import Moya

class SBSectionController: ASCollectionSectionController {
    private(set) weak var viewModel: SBViewModel?

    var onUnathorizedError: (() -> Void)?

    init(viewModel: SBViewModel) {
        self.viewModel = viewModel

        super.init()
    }

    override func didUpdate(to object: Any) {
        self.viewModel = object as? SBViewModel

        guard let viewModel = self.viewModel else {
            return
        }

        var items = [ListDiffable]()
        items.append(DateCell())
        if !viewModel.minimized {
            items.append(contentsOf: viewModel.items)
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
    }

    // MARK: - Methods

    private func toggle() {
        if let viewModel = self.viewModel,
            !viewModel.items.isEmpty {
            viewModel.minimized = !viewModel.minimized

            var items = [ListDiffable]()
            items.append(DateCell())
            if !viewModel.minimized {
                items.append(contentsOf: viewModel.items)
            }

            set(items: items, animated: false, completion: nil)
        }
    }
}

extension SBSectionController: ASSectionController {
    func nodeBlockForItem(at index: Int) -> ASCellNodeBlock {
        guard index < items.count,
            let viewModel = self.viewModel else {
                return {
                    return ASCellNode()
                }
        }

        if (items[index] as? SBViewModel) != nil {
            return {
                let separatorInset = index == 1
                    ? ItemCell.SeparatorInset(
                        left: App.Layout.itemSpacingMedium,
                        right: 0)
                    : ItemCell.SeparatorInset(
                        left: App.Layout.itemSpacingMedium,
                        right: App.Layout.itemSpacingMedium)
                let bottomInset: CGFloat = index == viewModel.items.count
                    ? App.Layout.itemSpacingMedium
                    : App.Layout.itemSpacingSmall
                let corners: UIRectCorner = index == viewModel.items.count
                    ? [UIRectCorner.bottomLeft, UIRectCorner.bottomRight]
                    : []
                return ItemCell(
                    title: "Two-line item",
                    subtitle: "Secondary",
                    separatorLeftRightInset: separatorInset,
                    bottomInset: bottomInset,
                    separatorHidden: false,
                    corners: corners
                )
            }
        }

        return {
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
            title: NSLocalizedString("s_and_b", comment: ""),
            itemColor: App.Color.azure,
            item1Count: 0,
            item1Title: "-",
            item2Count: 0,
            item2Title: "-",
            item3Count: 0,
            item3Title: "-",
            showAddButton: false,
            corners: corners,
            minimized: viewModel.minimized,
            didTapAddButton: {
                print("Did tap button in suggestion section  ...")
        })

        let cell = DashboardCell(config: config)
        cell.didTapToggle = { [weak self] in
            print("Toggle tapped ...")
            self?.toggle()
        }
        cell.didTapAdd = {
            print("Add pressed ...")
        }
        return cell
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
                items.append(contentsOf: viewModel.items)
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

extension SBSectionController: RefreshingSectionControllerType {
    func refreshContent(with completion: (() -> Void)?) {
        if let completion = completion {
            completion()
        }
    }
}
