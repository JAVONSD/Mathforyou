//
//  AppTabBarController.swift
//  Life
//
//  Created by Shyngys Kassymov on 14.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material

class AppTabBarController: TabsController {

    override func prepare() {
        super.prepare()

        view.backgroundColor = App.Color.whiteSmoke

        tabBar.setLineColor(UIColor.clear, for: .selected)

        tabBar.setTabItemsColor(App.Color.coolGrey, for: .normal)
        tabBar.setTabItemsColor(App.Color.azure, for: .selected)
        tabBar.setTabItemsColor(UIColor.black, for: .highlighted)

        tabBarAlignment = .bottom
        tabBar.tabBarStyle = .nonScrollable
        tabBar.dividerColor = nil
        tabBar.lineHeight = 0.0
        tabBar.lineAlignment = .bottom
        tabBar.backgroundColor = App.Color.paleGreyTwo
    }

}
