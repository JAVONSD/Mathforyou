//
//  BIBoardViewController.swift
//  Life
//
//  Created by Shyngys Kassymov on 14.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material
import SnapKit

class BIBoardViewController: UIViewController, ViewModelBased, Stepper {
    typealias ViewModelType = BIBoardViewModel
    var viewModel: BIBoardViewModel!

    var onUnathorizedError: (() -> Void)?

    private lazy var label = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    // MARK: - UI

    private func setupUI() {
        view.backgroundColor = App.Color.whiteSmoke

        label.text = "BI Board"
        label.textAlignment = .center
        view.addSubview(label)
        label.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }
            make.edges.equalTo(self.view)
        }
    }

}
