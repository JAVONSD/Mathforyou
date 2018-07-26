//
//  EmployeesSectionController.swift
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

class EmployeesSectionController: ASCollectionSectionController {
    private(set) weak var viewModel: StuffViewModel?

    var onUnathorizedError: (() -> Void)?
    var didSelectStuff: (() -> Void)?
    var didSelectEmployee: ((Employee) -> Void)?

    let disposeBag = DisposeBag()

    init(viewModel: StuffViewModel) {
        self.viewModel = viewModel

        super.init()
    }

    override func didUpdate(to object: Any) {
        self.viewModel = object as? StuffViewModel
        updateContents()
    }

    private func updateContents() {
        guard let viewModel = self.viewModel else {
            return
        }

        var items = [ListDiffable]()
        items.append(DateCell())
        if !viewModel.minimized {
            items.append(contentsOf: viewModel.birthdaysViewModel.employees as [ListDiffable])
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
        if index == 0, let didSelectStuff = didSelectStuff {
            didSelectStuff()
        } else if let viewModel = viewModel,
            let didSelectEmployee = didSelectEmployee {
            didSelectEmployee(viewModel.birthdaysViewModel.employees[index - 1].employee)
        }
    }

    // MARK: - Methods

    private func toggle() {
        if let viewModel = self.viewModel,
            !viewModel.birthdaysViewModel.employees.isEmpty {
            viewModel.minimized = !viewModel.minimized
            updateContents()
        }
    }
}

extension EmployeesSectionController: ASSectionController {
    private func dashboardCell(_ viewModel: StuffViewModel) -> () -> ASCellNode {
        return {
            let corners = viewModel.minimized
                ? UIRectCorner.allCorners
                : [UIRectCorner.topLeft, UIRectCorner.topRight]
            let config = DashboardCell.Config(
                image: "",
                title: NSLocalizedString("employees", comment: ""),
                itemColor: .black,
                item1Count: viewModel.employeesViewModel.employees.value.count,
                item1Title: NSLocalizedString("total_count_short", comment: ""),
                item2Count: viewModel.birthdaysViewModel.employees.count,
                item2Title: NSLocalizedString("birthdays_count_short", comment: ""),
                item3Count: viewModel.vacanciesViewModel.vacancies.count,
                item3Title: NSLocalizedString("vacancies_count_short", comment: ""),
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

        if let employee = items[index] as? EmployeeViewModel {
            return {
                let separatorInset = index == 1
                    ? ItemCell.SeparatorInset(
                        left: App.Layout.itemSpacingMedium,
                        right: 0)
                    : ItemCell.SeparatorInset(
                        left: App.Layout.itemSpacingMedium,
                        right: App.Layout.itemSpacingMedium)
                let bottomInset: CGFloat = index == viewModel.birthdaysViewModel.employees.count
                    ? App.Layout.itemSpacingMedium
                    : App.Layout.itemSpacingSmall
                let corners: UIRectCorner = index == viewModel.birthdaysViewModel.employees.count
                    ? [UIRectCorner.bottomLeft, UIRectCorner.bottomRight]
                    : []
                return ItemCell(
                    title: employee.employee.fullname,
                    subtitle: employee.employee.jobPosition,
                    separatorLeftRightInset: separatorInset,
                    bottomInset: bottomInset,
                    separatorHidden: false,
                    corners: corners
                )
            }
        }

        return dashboardCell(viewModel)
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
                items.append(contentsOf: viewModel.allItems)
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

extension EmployeesSectionController: RefreshingSectionControllerType {
    func refreshContent(with completion: (() -> Void)?) {
        viewModel?.employeesViewModel.getEmployees()
        viewModel?.employeesViewModel.onSuccess
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.updateContents()
                if let completion = completion {
                    completion()
                }
            })
            .disposed(by: disposeBag)
        viewModel?.employeesViewModel.onError
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                if let moyaError = error as? MoyaError,
                    moyaError.response?.statusCode == 401,
                    let onUnathorizedError = self?.onUnathorizedError {
                    onUnathorizedError()
                }
                self?.updateContents()
                if let completion = completion {
                    completion()
                }
            })
            .disposed(by: disposeBag)
        viewModel?.birthdaysViewModel.getBirthdays { [weak self] error in
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
        viewModel?.vacanciesViewModel.getVacancies { [weak self] error in
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




