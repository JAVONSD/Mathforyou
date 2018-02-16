//
//  StuffViewController.swift
//  Life
//
//  Created by Shyngys Kassymov on 16.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import Material

class StuffViewController: TabsController {

    private var previousShadowHidden = false

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let navVC = navigationController as? AppToolbarController {
            previousShadowHidden = navVC.shadowHidden
            navVC.setShadow(hidden: true)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let navVC = navigationController as? AppToolbarController {
            navVC.setShadow(hidden: previousShadowHidden)
        }
    }

    override func prepare() {
        super.prepare()

        view.backgroundColor = App.Color.whiteSmoke

        tabBar.setLineColor(App.Color.azure, for: .selected)

        tabBar.setTabItemsColor(App.Color.slateGrey, for: .normal)
        tabBar.setTabItemsColor(UIColor.black, for: .selected)
        tabBar.setTabItemsColor(UIColor.black, for: .highlighted)

        tabBarAlignment = .top
        tabBar.tabBarStyle = .nonScrollable
        tabBar.dividerColor = nil
        tabBar.lineHeight = 2.0
        tabBar.lineAlignment = .bottom
        tabBar.backgroundColor = App.Color.white
        tabBar.tabItemsContentEdgeInsetsPreset = .none
        tabBar.tabItemsInterimSpacePreset = .none

        tabBar.shadowColor = App.Color.shadows
        tabBar.depth = Depth(offset: Offset.init(horizontal: 0, vertical: 1), opacity: 1, radius: 6)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    // MARK: - Methods

    public static var configuredVC: StuffViewController {
        let vsc = [
            EmployeesViewController.instantiate(withViewModel: EmployeesViewModel()),
            BirthdaysViewController.instantiate(withViewModel: BirthdaysViewModel()),
            VacanciesViewController.instantiate(withViewModel: VacanciesViewModel())
        ]
        return StuffViewController(viewControllers: vsc)
    }

}
