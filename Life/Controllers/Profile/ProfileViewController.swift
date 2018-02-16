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

    private var previousShadowHidden = false

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.titleLabel.text = NSLocalizedString("profile", comment: "")
        navigationItem.titleLabel.font = App.Font.headline
        navigationItem.titleLabel.textAlignment = .left
        navigationItem.titleLabel.textColor = UIColor.black
    }

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
        tabBar.tabBarStyle = .auto
        tabBar.dividerColor = nil
        tabBar.lineHeight = 2.0
        tabBar.lineAlignment = .bottom
        tabBar.backgroundColor = App.Color.white
        tabBar.tabItemsContentEdgeInsetsPreset = .horizontally4

        tabBar.shadowColor = App.Color.shadows
        tabBar.depth = Depth(offset: Offset.init(horizontal: 0, vertical: 1), opacity: 1, radius: 6)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
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
