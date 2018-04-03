//
//  TasksAndRequestsSectionController.swift
//  Life
//
//  Created by Shyngys Kassymov on 20.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import IGListKit
import Moya
import RxSwift

class TasksAndRequestsSectionController: ASCollectionSectionController {
    private(set) weak var viewModel: TasksAndRequestsViewModel?

    private let disposeBag = DisposeBag()
    private var tasksAndRequestsObservable: Observable<[ListDiffable]>

    var onUnathorizedError: (() -> Void)?
    var didTapOnTasksAndRequests: (() -> Void)?
    var didTapOnTaskOrRequest: ((Int) -> Void)?
    var didTapAddRequest: (() -> Void)?
    var didTapViewAll: (() -> Void)?

    init(viewModel: TasksAndRequestsViewModel) {
        self.viewModel = viewModel
        tasksAndRequestsObservable = viewModel.tasksAndRequestsSubject.asObservable()

        super.init()

        tasksAndRequestsObservable
            .bind { [weak self] _ in
                self?.updateContents()
            }.disposed(by: disposeBag)
    }

    override func didUpdate(to object: Any) {
        self.viewModel = object as? TasksAndRequestsViewModel
        updateContents()
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        return ASIGListSectionControllerMethods.cellForItem(at: index, sectionController: self)
    }

    override func sizeForItem(at index: Int) -> CGSize {
        return ASIGListSectionControllerMethods.sizeForItem(at: index)
    }

    override func didSelectItem(at index: Int) {
        if index == 0 {
            if let didTapOnTasksAndRequests = didTapOnTasksAndRequests {
                didTapOnTasksAndRequests()
            }
        } else if (viewModel?.items.count ?? 0) > 5 && index == self.items.count - 1 {
            if let didTapViewAll = didTapViewAll {
                didTapViewAll()
            }
        } else {
            if let didTapOnTaskOrRequest = didTapOnTaskOrRequest {
                didTapOnTaskOrRequest(index - 1)
            }
        }
    }

    // MARK: - Methods

    private func toggle() {
        if let viewModel = self.viewModel,
            !viewModel.items.isEmpty {
            viewModel.minimized = !viewModel.minimized
            updateContents()
        }
    }

    private func updateContents() {
        guard let viewModel = self.viewModel else {
            return
        }

        var items = [ListDiffable]()
        items.append(DateCell())
        if !viewModel.minimized {
            items.append(contentsOf: Array(viewModel.items.prefix(5)))
        }
        if !viewModel.minimized && viewModel.items.count > 5 {
            items.append(NSString(string: "ViewMoreCell"))
        }

        set(items: items, animated: false, completion: nil)
    }
}

extension TasksAndRequestsSectionController: ASSectionController {
    private func taskCell(
        _ index: Int,
        _ viewModel: TasksAndRequestsViewModel,
        _ task: TaskViewModel) -> () -> ASCellNode {
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
            var detailText = task.task.statusCode.name
            if let date = task.task.endDate {
                let fmtDate = date.prettyDateString(format: "dd.MM.yyyy HH:mm")
                detailText += "\n\(fmtDate)"
            }
            return ItemCell(
                title: task.task.topic,
                subtitle: detailText,
                separatorLeftRightInset: separatorInset,
                bottomInset: bottomInset,
                separatorHidden: false,
                corners: corners
            )
        }
    }

    private func requestCell(
        _ index: Int,
        _ viewModel: TasksAndRequestsViewModel,
        _ request: RequestViewModel) -> () -> ASCellNode {
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
                title: request.request.topic,
                subtitle: request.request.taskStatus,
                separatorLeftRightInset: separatorInset,
                bottomInset: bottomInset,
                separatorHidden: false,
                corners: corners
            )
        }
    }

    func nodeBlockForItem(at index: Int) -> ASCellNodeBlock {
        guard index < items.count,
            let viewModel = self.viewModel else {
                return {
                    return ASCellNode()
                }
        }

        if let task = items[index] as? TaskViewModel {
            return taskCell(index, viewModel, task)
        } else if let request = items[index] as? RequestViewModel {
            return requestCell(index, viewModel, request)
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
            title: NSLocalizedString("tasks_and_requests", comment: ""),
            itemColor: App.Color.azure,
            item1Count: viewModel.items.count,
            item1Title: NSLocalizedString("total_count_short", comment: ""),
            item2Count: viewModel.inboxCount,
            item2Title: NSLocalizedString("inbox_count_short", comment: ""),
            item3Count: viewModel.outboxCount,
            item3Title: NSLocalizedString("outbox_count_short", comment: ""),
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
            if let didTapAddRequest = self.didTapAddRequest {
                didTapAddRequest()
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

extension TasksAndRequestsSectionController: RefreshingSectionControllerType {
    func refreshContent(with completion: (() -> Void)?) {
        viewModel?.getAllTasksAndRequests()
        viewModel?.isLoadingSubject.subscribe(onNext: { isLoading in
            if !isLoading, let completion = completion {
                completion()
            }
        }).disposed(by: disposeBag)
        viewModel?.errorSubject.subscribe(onNext: { [weak self] error in
            if let moyaError = error as? MoyaError,
                moyaError.response?.statusCode == 401,
                let onUnathorizedError = self?.onUnathorizedError {
                onUnathorizedError()
            }
        }).disposed(by: disposeBag)
    }
}
