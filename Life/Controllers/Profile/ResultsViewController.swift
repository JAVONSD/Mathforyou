//
//  ResultsViewController.swift
//  Life
//
//  Created by Shyngys Kassymov on 12.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material

class ResultsViewController: UIViewController {

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
        tabItem.title = NSLocalizedString("results", comment: "").uppercased()
        tabItem.titleLabel?.font = App.Font.buttonSmall
    }

}
