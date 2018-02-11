//
//  LoginViewController.swift
//  Life
//
//  Created by Shyngys Kassymov on 11.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import SnapKit

class LoginViewController: UIViewController {
    private var loginView: LoginView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    // MARK: - UI

    private func setupUI() {
        loginView = LoginView(frame: .zero)
        view.addSubview(loginView)
        loginView.snp.makeConstraints({ [weak self] (make) in
            guard let `self` = self else { return }
            make.edges.equalTo(self.view)
        })
    }

}
