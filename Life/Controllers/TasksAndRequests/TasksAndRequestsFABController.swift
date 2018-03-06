//
//  TasksAndRequestsFABController.swift
//  Life
//
//  Created by Shyngys Kassymov on 21.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa
import SnapKit

class TasksAndRequestsFABController: FABMenuController {

    private var fabButton: FABButton!

    let disposeBag = DisposeBag()
    var didTapAddButton: ((Request.Category, @escaping (() -> Void)) -> Void)?
    var didTapAddTaskButton: ((@escaping (() -> Void)) -> Void)?

    override func prepare() {
        super.prepare()

        setupFabButton()
    }

    // MARK: - UI

    private func setupFabButton() {
        fabButton = FABButton(image: Icon.cm.add, tintColor: .white)
        fabButton.pulseColor = .white
        fabButton.backgroundColor = App.Color.azure
        fabButton.shadowColor = App.Color.black12
        fabButton.depth = Depth(offset: Offset.init(horizontal: 0, vertical: 12), opacity: 1, radius: 12)

        fabMenu.fabButton = fabButton
        fabMenu.fabMenuItemSize = CGSize(
            width: App.Layout.itemSpacingMedium * 2,
            height: App.Layout.itemSpacingMedium * 2
        )
        fabMenuBacking = .fade

        setupFABMenuItems()

        fabMenu.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.view).inset(App.Layout.sideOffset)
            make.right.equalTo(self.view).inset(App.Layout.sideOffset)
            make.size.equalTo(CGSize(width: 56, height: 56))
        }
    }

    private func setupFABMenuItems() {
        let taskItem = setupFABMenuItem(
            title: NSLocalizedString("new_task", comment: ""),
            onTap: { [weak self] in
                if let didTapAddTaskButton = self?.didTapAddTaskButton {
                    didTapAddTaskButton({ [weak self] in
                        if let vc = self?.childViewControllers.first as? TasksAndRequestsViewController {
                            vc.viewModel?.getAllTasks()
                        }
                    })
                }
            }
        )
        let requestItem = setupFABMenuItem(
            title: NSLocalizedString("new_request", comment: ""),
            shouldClose: false,
            onTap: { [weak self] in
                if let fabMenu = self?.fabMenu {
                    self?.setupRequestsFABMenuItems()
                    fabMenu.open()
                }
            }
        )
        fabMenu.fabMenuItems = [taskItem, requestItem].reversed()
        fabMenu.layoutSubviews()
    }

    private func setupRequestsFABMenuItems() {
        let categories = Request.Category.all
        var menuItems = [FABMenuItem]()
        for category in categories {
            let menuItem = setupFABMenuItem(title: category.name, onTap: { [weak self] in
                if let didTapAddButton = self?.didTapAddButton {
                    didTapAddButton(category) { [weak self] in
                        if let vc = self?.childViewControllers.first as? TasksAndRequestsViewController {
                            vc.viewModel?.getAllRequests()
                        }
                    }
                }
            })
            menuItems.append(menuItem)
        }
        fabMenu.fabMenuItems = menuItems.reversed()
        fabMenu.layoutSubviews()
    }

    private func setupFABMenuItem(
        title: String,
        shouldClose: Bool = true,
        onTap: @escaping (() -> Void)) -> FABMenuItem {
        let menuItem = FABMenuItem()
        menuItem.title = title
        menuItem.titleLabel.backgroundColor = .clear
        menuItem.titleLabel.font = App.Font.body
        menuItem.titleLabel.textColor = .black
        menuItem.fabButton.image = Icon.cm.add
        menuItem.fabButton.tintColor = .white
        menuItem.fabButton.pulseColor = .white
        menuItem.fabButton.backgroundColor = App.Color.azure
        menuItem.fabButton.rx.tap.asDriver().throttle(0.5).drive(onNext: { [weak self] in
            onTap()

            if shouldClose {
                self?.fabMenu.close(isTriggeredByUserInteraction: true)
            }
        }).disposed(by: disposeBag)

        return menuItem
    }

    // MARK: - FABMenuDelegate

    func fabMenuWillOpen(fabMenu: FABMenu) {
        fabButton.backgroundColor = App.Color.paleGreyTwo
        fabButton.image = Icon.cm.close
        fabButton.tintColor = App.Color.coolGrey
    }

    func fabMenuWillClose(fabMenu: FABMenu) {
        fabButton.backgroundColor = App.Color.azure
        fabButton.image = Icon.cm.add
        fabButton.tintColor = UIColor.white
    }

    func fabMenuDidClose(fabMenu: FABMenu) {
        setupFABMenuItems()
        isUserInteractionEnabled = true
    }

}
