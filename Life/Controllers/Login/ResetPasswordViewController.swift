//
//  ResetPasswordViewController.swift
//  Life
//
//  Created by Shyngys Kassymov on 11.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import SnapKit

class ResetPasswordViewController: UIViewController, ViewModelBased, Stepper {
    typealias ViewModelType = ResetPasswordViewModel
    var viewModel: ResetPasswordViewModel!

    private var resetPasswordView: ResetPasswordView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    // MARK: - UI

    private func setupUI() {
        resetPasswordView = ResetPasswordView(frame: .zero)
        view.addSubview(resetPasswordView)
        resetPasswordView.snp.makeConstraints({ [weak self] (make) in
            guard let `self` = self else { return }
            make.edges.equalTo(self.view)
        })
    }
}
