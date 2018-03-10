//
//  QuestionnairesSectionController.swift
//  Life
//
//  Created by Shyngys Kassymov on 20.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import IGListKit
import Moya

class QuestionnairesSectionController: ASCollectionSectionController {
    private(set) weak var viewModel: QuestionnairesViewModel?

    var onUnathorizedError: (() -> Void)?

    init(viewModel: QuestionnairesViewModel) {
        self.viewModel = viewModel

        super.init()
    }

    override func didUpdate(to object: Any) {
        self.viewModel = object as? QuestionnairesViewModel
        updateContents()
    }

    private func updateContents() {
        guard let viewModel = self.viewModel else {
            return
        }

        var items = [ListDiffable]()
        items.append(DateCell())
        if !viewModel.minimized {
            items.append(contentsOf: viewModel.questionnaires as [ListDiffable])
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
            !viewModel.popularQuestionnaires.isEmpty {
            viewModel.minimized = !viewModel.minimized
            updateContents()
        }
    }
}

extension QuestionnairesSectionController: ASSectionController {
    func nodeBlockForItem(at index: Int) -> ASCellNodeBlock {
        guard index < items.count,
            let viewModel = self.viewModel else {
                return {
                    return ASCellNode()
                }
        }

        if let quesionnaire = items[index] as? QuestionnaireViewModel {
            return {
                let separatorInset = index == 1
                    ? ItemCell.SeparatorInset(
                        left: App.Layout.itemSpacingMedium,
                        right: 0)
                    : ItemCell.SeparatorInset(
                        left: App.Layout.itemSpacingMedium,
                        right: App.Layout.itemSpacingMedium)
                let bottomInset: CGFloat = index == viewModel.questionnaires.count
                    ? App.Layout.itemSpacingMedium
                    : App.Layout.itemSpacingSmall
                let corners: UIRectCorner = index == viewModel.questionnaires.count
                    ? [UIRectCorner.bottomLeft, UIRectCorner.bottomRight]
                    : []
                return ItemCell(
                    title: quesionnaire.questionnaire.title,
                    subtitle: quesionnaire.questionnaire.createDate.prettyDateOrTimeAgoString(),
                    separatorLeftRightInset: separatorInset,
                    bottomInset: bottomInset,
                    separatorHidden: false,
                    corners: corners
                )
            }
        }

        return {
            return self.dashboardCell(viewModel: viewModel)
        }
    }

    private func dashboardCell(viewModel: QuestionnairesViewModel) -> ASCellNode {
        let corners = viewModel.minimized
            ? UIRectCorner.allCorners
            : [UIRectCorner.topLeft, UIRectCorner.topRight]
        let config = DashboardCell.Config(
            image: "",
            title: NSLocalizedString("questionnaires", comment: ""),
            itemColor: .black,
            item1Count: viewModel.questionnaires.count,
            item1Title: NSLocalizedString("total_count_short", comment: ""),
            item2Count: viewModel.questionnaires.count,
            item2Title: NSLocalizedString("total_count_short", comment: ""),
            item3Count: viewModel.popularQuestionnaires.count,
            item3Title: NSLocalizedString("popular_count_short", comment: ""),
            showAddButton: false,
            corners: corners,
            minimized: viewModel.minimized,
            didTapAddButton: {
                print("Did tap button in suggestion section  ...")
        })

        let cell = DashboardCell(config: config)
        cell.didTapToggle = { [weak self] in
            self?.toggle()
        }
        cell.didTapAdd = {
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
                items.append(contentsOf: viewModel.questionnaires as [ListDiffable])
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

extension QuestionnairesSectionController: RefreshingSectionControllerType {
    func refreshContent(with completion: (() -> Void)?) {
        viewModel?.getQuestionnaires { [weak self] error in
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
        viewModel?.getPopularQuestionnaires { [weak self] error in
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
