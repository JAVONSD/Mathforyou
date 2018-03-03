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

    override func prepare() {
        super.prepare()

        setupFabButton()
    }

    // MARK: - Actions

    private func handleFABMenuItem(category: Request.Category) {
        if let didTapAddButton = didTapAddButton {
            didTapAddButton(category) { [weak self] in
                if let vc = self?.childViewControllers.first as? TasksAndRequestsViewController {
                    vc.viewModel?.getAllRequests()
                }
            }
        }

        fabMenuWillClose(fabMenu: fabMenu)
        fabMenu.close()
    }

    // MARK: - UI

    private func setupFabButton() {
        fabButton = FABButton(image: Icon.cm.add, tintColor: .white)
        fabButton.pulseColor = .white
        fabButton.backgroundColor = App.Color.azure

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
        let categories = Request.Category.all
        var menuItems = [FABMenuItem]()
        for category in categories {
            let menuItem = setupFABMenuItem(category: category)
            menuItems.append(menuItem)
        }
        fabMenu.fabMenuItems = menuItems.reversed()
    }

    private func setupFABMenuItem(category: Request.Category) -> FABMenuItem {
        let menuItem = FABMenuItem()
        menuItem.title = category.name
        menuItem.titleLabel.backgroundColor = .clear
        menuItem.titleLabel.font = App.Font.body
        menuItem.titleLabel.textColor = .black
        menuItem.fabButton.image = Icon.cm.add
        menuItem.fabButton.tintColor = .white
        menuItem.fabButton.pulseColor = .white
        menuItem.fabButton.backgroundColor = App.Color.azure
        menuItem.fabButton.rx.tap.asDriver().throttle(0.5).drive(onNext: { [weak self] in
            self?.handleFABMenuItem(category: category)
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

}
