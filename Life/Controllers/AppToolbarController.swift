//
//  AppToolbarController.swift
//  Life
//
//  Created by Shyngys Kassymov on 12.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material

class AppToolbarController: ToolbarController {
    private var menuButton: IconButton!

    open override func prepare() {
        super.prepare()

        setupMenuButton()
        setupStatusBar()
        setupToolbar()
    }

    // MARK: - UI

    private func setupMenuButton() {
        menuButton = IconButton(image: #imageLiteral(resourceName: "back"), tintColor: App.Color.azure)
        menuButton.pulseColor = App.Color.azure
    }

    private func setupStatusBar() {
        statusBarStyle = .lightContent
        statusBar.backgroundColor = App.Color.white
    }

    private func setupToolbar() {
        toolbar.depthPreset = .none
        toolbar.backgroundColor = App.Color.white

        toolbar.title = NSLocalizedString("profile", comment: "")
        toolbar.titleLabel.font = App.Font.headline
        toolbar.titleLabel.textColor = .black
        toolbar.titleLabel.textAlignment = .left

        toolbar.leftViews = [menuButton]
    }

}
