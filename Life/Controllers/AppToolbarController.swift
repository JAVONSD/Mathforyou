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
        statusBar.layer.zPosition = toolbar.layer.zPosition + 1
    }

    private func setupToolbar() {
        toolbar.shadowColor = UIColor.black.withAlphaComponent(0.16)
        toolbar.depth = Depth(offset: Offset.init(horizontal: 0, vertical: 1), opacity: 1, radius: 6)

        toolbar.backgroundColor = App.Color.white

        toolbar.titleLabel.font = App.Font.headline
        toolbar.titleLabel.textColor = .black
        toolbar.titleLabel.textAlignment = .left
    }

}
