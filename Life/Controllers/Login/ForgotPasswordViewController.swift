//
//  ForgotPasswordViewController.swift
//  Life
//
//  Created by Shyngys Kassymov on 11.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import SnapKit

class ForgotPasswordViewController: UIViewController, ViewModelBased, Stepper {
    typealias ViewModelType = ForgotPasswordViewModel
    var viewModel: ForgotPasswordViewModel!

    private var forgotPasswordView: ForgotPasswordView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - UI

    private func setupUI() {
        forgotPasswordView = ForgotPasswordView(login: viewModel.login)
        forgotPasswordView.didTapClose = { [weak self] in
            guard let `self` = self else { return }
            self.step.accept(AppStep.forgotPasswordCancel)
        }
        view.addSubview(forgotPasswordView)
        forgotPasswordView.snp.makeConstraints({ [weak self] (make) in
            guard let `self` = self else { return }
            make.edges.equalTo(self.view)
        })
    }
}
