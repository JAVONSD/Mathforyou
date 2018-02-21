//
//  TasksAndRequestsFABController.swift
//  Life
//
//  Created by Shyngys Kassymov on 21.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material
import SnapKit

class TasksAndRequestsFABController: FABMenuController {

    private var fabButton: FABButton!

    private var itFABMenuItem: FABMenuItem!
    private var bookkeepingFABMenuItem: FABMenuItem!
    private var hrFABMenuItem: FABMenuItem!
    private var employeeFABMenuItem: FABMenuItem!

    override func prepare() {
        super.prepare()

        setupFabButton()
    }

    // MARK: - Actions

    @objc
    private func handleItButton() {

    }

    @objc
    private func handleBookkeepingButton() {

    }

    @objc
    private func handleHrButton() {

    }

    @objc
    private func handleEmployeeButton() {

    }

    // MARK: - UI

    private func setupFabButton() {
        setupItFABMenuItem()
        setupBookkeepingFABMenuItem()
        setupHrFABMenuItem()
        setupEmployeeFABMenuItem()

        fabButton = FABButton(image: Icon.cm.add, tintColor: .white)
        fabButton.pulseColor = .white
        fabButton.backgroundColor = App.Color.azure

        fabMenu.fabButton = fabButton
        fabMenu.fabMenuItemSize = CGSize(
            width: App.Layout.itemSpacingMedium * 2,
            height: App.Layout.itemSpacingMedium * 2
        )
        fabMenu.fabMenuItems = [
            itFABMenuItem,
            bookkeepingFABMenuItem,
            hrFABMenuItem,
            employeeFABMenuItem
        ].reversed()
        fabMenuBacking = .fade

        fabMenu.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.view).inset(App.Layout.sideOffset)
            make.right.equalTo(self.view).inset(App.Layout.sideOffset)
            make.size.equalTo(CGSize(width: 56, height: 56))
        }
    }

    private func setupItFABMenuItem() {
        itFABMenuItem = FABMenuItem()
        itFABMenuItem.title = NSLocalizedString("it_department", comment: "")
        itFABMenuItem.titleLabel.backgroundColor = .clear
        itFABMenuItem.titleLabel.font = App.Font.body
        itFABMenuItem.titleLabel.textColor = .black
        itFABMenuItem.fabButton.image = Icon.cm.add
        itFABMenuItem.fabButton.tintColor = .white
        itFABMenuItem.fabButton.pulseColor = .white
        itFABMenuItem.fabButton.backgroundColor = App.Color.azure
        itFABMenuItem.fabButton.addTarget(
            self, action: #selector(handleItButton), for: .touchUpInside)
    }

    private func setupBookkeepingFABMenuItem() {
        bookkeepingFABMenuItem = FABMenuItem()
        bookkeepingFABMenuItem.title = NSLocalizedString("bookkeeping", comment: "")
        bookkeepingFABMenuItem.titleLabel.backgroundColor = .clear
        bookkeepingFABMenuItem.titleLabel.font = App.Font.body
        bookkeepingFABMenuItem.titleLabel.textColor = .black
        bookkeepingFABMenuItem.fabButton.image = Icon.cm.add
        bookkeepingFABMenuItem.fabButton.tintColor = .white
        bookkeepingFABMenuItem.fabButton.pulseColor = .white
        bookkeepingFABMenuItem.fabButton.backgroundColor = App.Color.azure
        bookkeepingFABMenuItem.fabButton.addTarget(
            self, action: #selector(handleBookkeepingButton), for: .touchUpInside)
    }

    private func setupHrFABMenuItem() {
        hrFABMenuItem = FABMenuItem()
        hrFABMenuItem.title = NSLocalizedString("hr_department", comment: "")
        hrFABMenuItem.titleLabel.backgroundColor = .clear
        hrFABMenuItem.titleLabel.font = App.Font.body
        hrFABMenuItem.titleLabel.textColor = .black
        hrFABMenuItem.fabButton.image = Icon.cm.add
        hrFABMenuItem.fabButton.tintColor = .white
        hrFABMenuItem.fabButton.pulseColor = .white
        hrFABMenuItem.fabButton.backgroundColor = App.Color.azure
        hrFABMenuItem.fabButton.addTarget(self, action: #selector(handleHrButton), for: .touchUpInside)
    }

    private func setupEmployeeFABMenuItem() {
        employeeFABMenuItem = FABMenuItem()
        employeeFABMenuItem.title = NSLocalizedString("to_employee", comment: "")
        employeeFABMenuItem.titleLabel.backgroundColor = .clear
        employeeFABMenuItem.titleLabel.font = App.Font.body
        employeeFABMenuItem.titleLabel.textColor = .black
        employeeFABMenuItem.fabButton.image = Icon.cm.add
        employeeFABMenuItem.fabButton.tintColor = .white
        employeeFABMenuItem.fabButton.pulseColor = .white
        employeeFABMenuItem.fabButton.backgroundColor = App.Color.azure
        employeeFABMenuItem.fabButton.addTarget(
            self, action: #selector(handleBookkeepingButton), for: .touchUpInside)
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
