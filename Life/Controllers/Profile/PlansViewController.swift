//
//  PlansViewController.swift
//  Life
//
//  Created by Shyngys Kassymov on 12.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material

class PlansViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        configUI()
    }

    // MARK: - UI

    private func configUI() {
        view.backgroundColor = App.Color.whiteSmoke

        setupTabItem()
    }

    private func setupTabItem() {
        tabItem.title = NSLocalizedString("plans", comment: "").uppercased()
        tabItem.titleLabel?.font = App.Font.buttonSmall
    }

}
