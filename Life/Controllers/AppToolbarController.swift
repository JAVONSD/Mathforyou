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

    open override func prepare() {
        super.prepare()

        setupStatusBar()
        setupToolbar()
    }

    // MARK: - UI

    private func setupStatusBar() {
        statusBarStyle = .lightContent
        statusBar.backgroundColor = App.Color.white
    }

    private func setupToolbar() {
        toolbar.depthPreset = .none
        toolbar.backgroundColor = App.Color.white

        toolbar.titleLabel.font = App.Font.headline
        toolbar.titleLabel.textColor = .black
        toolbar.titleLabel.textAlignment = .left
    }

}
