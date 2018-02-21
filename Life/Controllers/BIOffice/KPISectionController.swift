//
//  KPISectionController.swift
//  Life
//
//  Created by Shyngys Kassymov on 20.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import IGListKit
import Moya

class KPISectionController: ASCollectionSectionController {
    private(set) weak var viewModel: KPIViewModel?

    var onUnathorizedError: (() -> Void)?

    init(viewModel: KPIViewModel) {
        self.viewModel = viewModel

        super.init()
    }

    override func didUpdate(to object: Any) {
        self.viewModel = object as? KPIViewModel

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

extension KPISectionController: ASSectionController {
    func nodeBlockForItem(at index: Int) -> ASCellNodeBlock {
        guard index < items.count,
            let viewModel = self.viewModel else {
                return {
                    return ASCellNode()
                }
        }

        if let _ = items[index] as? KPIViewModel {
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
            title: NSLocalizedString("kpi_projects", comment: ""),
            itemColor: App.Color.azure,
            item1Count: 18,
            item1Title: "new",
            item2Count: 20,
            item2Title: "new",
            item3Count: 3,
            item3Title: "new",
            showAddButton: true,
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

extension KPISectionController: RefreshingSectionControllerType {
    func refreshContent(with completion: (() -> Void)?) {
        if let completion = completion {
            completion()
        }
    }
}
