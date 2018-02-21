//
//  AppToolbarController.swift
//  Life
//
//  Created by Shyngys Kassymov on 12.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material

class AppToolbarController: NavigationController, Stepper {

    private(set) var shadowHidden = true

    open override func prepare() {
        super.prepare()

        setupStatusBar()
        setupToolbar()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    // MARK: - Methods

    public func setShadow(hidden: Bool) {
        shadowHidden = hidden

        if let navBar = navigationBar as? NavigationBar {
            navBar.shadowColor = hidden ? UIColor.clear : UIColor.black.withAlphaComponent(0.16)

            let depthNone = Depth(preset: .none)
            let depthExist = Depth(offset: Offset.init(horizontal: 0, vertical: 1), opacity: 1, radius: 6)
            navBar.depth =  hidden ? depthNone : depthExist

            navBar.interimSpacePreset = .none
            navBar.contentEdgeInsets = .init(
                top: 4,
                left: 0,
                bottom: 4,
                right: 6
            )
        }
    }

    // MARK: - UI

    private func setupStatusBar() {
        statusBarStyle = .default
    }

    private func setupToolbar() {
        if let navBar = navigationBar as? NavigationBar {
            navBar.backButtonImage = #imageLiteral(resourceName: "back")

            navBar.backgroundColor = App.Color.white
        }

        setShadow(hidden: false)
    }

}
