//
//  MenuViewController.swift
//  Life
//
//  Created by Shyngys Kassymov on 14.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material
import SnapKit

class MenuViewController: UIViewController, ViewModelBased, Stepper {
    typealias ViewModelType = MenuViewModel
    var viewModel: MenuViewModel!

    private lazy var label = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    // MARK: - UI

    private func setupUI() {
        label.text = "Menu"
        label.textAlignment = .center
        view.addSubview(label)
        label.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }
            make.edges.equalTo(self.view)
        }
    }

}
