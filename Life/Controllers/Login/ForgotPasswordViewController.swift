//
//  ForgotPasswordViewController.swift
//  Life
//
//  Created by Shyngys Kassymov on 11.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import SnapKit

class ForgotPasswordViewController: UIViewController {
    private var forgotPasswordView: ForgotPasswordView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    // MARK: - UI

    private func setupUI() {
        forgotPasswordView = ForgotPasswordView(frame: .zero)
        view.addSubview(forgotPasswordView)
        forgotPasswordView.snp.makeConstraints({ [weak self] (make) in
            guard let `self` = self else { return }
            make.edges.equalTo(self.view)
        })
    }
}
