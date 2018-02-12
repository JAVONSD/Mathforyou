//
//  ProfileViewController.swift
//  Life
//
//  Created by Shyngys Kassymov on 12.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material

class ProfileViewController: TabsController {

    override func prepare() {
        super.prepare()

        view.backgroundColor = App.Color.whiteSmoke

        tabBar.setLineColor(App.Color.azure, for: .selected)

        tabBar.setTabItemsColor(App.Color.slateGrey, for: .normal)
        tabBar.setTabItemsColor(UIColor.black, for: .selected)
        tabBar.setTabItemsColor(UIColor.black, for: .highlighted)

        tabBarAlignment = .top
        tabBar.tabBarStyle = .auto
        tabBar.dividerColor = nil
        tabBar.lineHeight = 2.0
        tabBar.lineAlignment = .bottom
        tabBar.backgroundColor = App.Color.white
        tabBar.tabItemsContentEdgeInsetsPreset = .horizontally4

        tabBar.shadowColor = App.Color.shadows
        tabBar.depth = Depth(offset: Offset.init(horizontal: 0, vertical: 1), opacity: 1, radius: 6)
    }

    // MARK: - Methods

    public static var configuredVC: ProfileViewController {
        let vsc = [
            MyInfoViewController(),
            ResultsViewController(),
            PlansViewController(),
            BenefitsViewController()
        ]
        return ProfileViewController(viewControllers: vsc)
    }

}
