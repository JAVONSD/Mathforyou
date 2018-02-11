//
//  LoginView.swift
//  Life
//
//  Created by Shyngys Kassymov on 11.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import DateToolsSwift
import DynamicColor
import Material
import SnapKit

class LoginView: UIView, MaskedTextFieldDelegateListener {

    private(set) var headerView: GradientView?
    private(set) var headerImageView: UIImageView?
    private(set) var phoneField: TextField?
    private(set) var passwordField: TextField?
    private(set) var loginButton: Button?
    private(set) var forgotPasswordView: UIView?
    private(set) var forgotPasswordLabel: UILabel?
    private(set) var forgotPasswordButton: FlatButton?
    private(set) var biGroupLabel: UILabel?

    private var maskedDelegate: MaskedTextFieldDelegate!

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupHeaderView()
        setupPhoneField()
        setupPasswordField()
        setupLoginButton()
        setupForgotPasswordView()
        setupBIGroupLabel()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI

    private func setupHeaderView() {
        headerView = GradientView()

        guard let headerView = headerView else { return }

        headerView.makeHorizontal()
        headerView.setGradient(colors: App.Color.blueGradient)

        headerView.layer.shadowColor = App.Color.black12.cgColor
        headerView.layer.shadowOffset = CGSize(width: 0, height: 6)
        headerView.layer.shadowRadius = 6
        headerView.layer.shadowOpacity = 1

        addSubview(headerView)
        headerView.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }

            make.top.equalTo(self)
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.height.equalTo(headerView.snp.width).multipliedBy(144.0 / 360.0)
        }

        setupHeaderImageView()
    }

    private func setupHeaderImageView() {
        headerImageView = UIImageView()

        guard let headerView = headerView,
            let headerImageView = headerImageView else {
            return
        }

        headerImageView.contentMode = .scaleAspectFit
        headerImageView.image = #imageLiteral(resourceName: "bi-logo-copy")

        headerView.addSubview(headerImageView)
        headerImageView.snp.makeConstraints { (make) in
            let width = 112.0
            make.centerX.equalTo(headerView)
            make.centerY.equalTo(headerView).offset(10)
            make.width.equalTo(width)
            make.height.equalTo(headerImageView.snp.width).multipliedBy(60.0 / width)
        }
    }

    private func setupPhoneField() {
        maskedDelegate = MaskedTextFieldDelegate(format: "{+7} ([000]) [000] [00] [00]")
        maskedDelegate.listener = self

        phoneField = TextField(frame: .zero)

        guard let headerView = headerView,
            let phoneField = phoneField else {
            return
        }

        phoneField.placeholder = NSLocalizedString("phone", comment: "")
        phoneField.delegate = maskedDelegate

        maskedDelegate.put(text: "+7 ", into: phoneField)

        addSubview(phoneField)
        phoneField.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }

            make.top.equalTo(headerView.snp.bottom).offset(App.Layout.itemSpacingMedium * 2)
            make.left.equalTo(self).inset(App.Layout.sideOffset)
            make.right.equalTo(self).inset(App.Layout.sideOffset)
        }
    }

    private func setupPasswordField() {
        passwordField = TextField(frame: .zero)
        passwordField?.placeholder = NSLocalizedString("password", comment: "")
        passwordField?.clearButtonMode = .whileEditing
        passwordField?.visibilityIconButton?.tintColor = App.Color.azure
        passwordField?.isVisibilityIconButtonEnabled = true

        guard let passwordField = passwordField,
            let phoneField = phoneField else {
            return
        }

        addSubview(passwordField)
        passwordField.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }

            make.top.equalTo(phoneField.snp.bottom).offset(App.Layout.itemSpacingMedium)
            make.left.equalTo(self).inset(App.Layout.sideOffset)
            make.right.equalTo(self).inset(App.Layout.sideOffset)
        }
    }

    private func setupLoginButton() {
        loginButton = Button(title: NSLocalizedString("login", comment: "").uppercased())

        guard let passwordField = passwordField,
            let loginButton = loginButton else {
            return
        }

        addSubview(loginButton)
        loginButton.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }

            make.top.equalTo(passwordField.snp.bottom).offset(App.Layout.itemSpacingBig)
            make.left.equalTo(self).inset(App.Layout.sideOffset)
            make.right.equalTo(self).inset(App.Layout.sideOffset)
        }
    }

    private func setupForgotPasswordView() {
        forgotPasswordView = UIView()

        guard let forgotPasswordView = forgotPasswordView,
            let loginButton = loginButton else {
            return
        }

        addSubview(forgotPasswordView)
        forgotPasswordView.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }

            make.top.equalTo(loginButton.snp.bottom).offset(App.Layout.itemSpacingMedium * 2)
            make.centerX.equalTo(self)
        }

        setupForgotPasswordLabel()
        setupForgotPasswordButton()
    }

    private func setupForgotPasswordLabel() {
        forgotPasswordLabel = UILabel()

        guard let forgotPasswordView = forgotPasswordView,
            let forgotPasswordLabel = forgotPasswordLabel else {
            return
        }

        forgotPasswordLabel.font = App.Font.footnote
        forgotPasswordLabel.textColor = App.Color.slateGrey
        forgotPasswordLabel.text = NSLocalizedString("forgot_password_descr", comment: "")

        addSubview(forgotPasswordLabel)
        forgotPasswordLabel.snp.makeConstraints { (make) in
            make.top.equalTo(forgotPasswordView)
            make.left.equalTo(forgotPasswordView)
            make.bottom.equalTo(forgotPasswordView)
        }
    }

    private func setupForgotPasswordButton() {
        forgotPasswordButton = FlatButton(
            title: NSLocalizedString("help", comment: ""),
            titleColor: App.Color.azure
        )

        guard let forgotPasswordView = forgotPasswordView,
            let forgotPasswordLabel = forgotPasswordLabel,
            let forgotPasswordButton = forgotPasswordButton else {
            return
        }

        forgotPasswordButton.titleLabel?.font = App.Font.footnote

        addSubview(forgotPasswordButton)
        forgotPasswordButton.snp.makeConstraints { (make) in
            make.top.equalTo(forgotPasswordView)
            make.left.equalTo(forgotPasswordLabel.snp.right).offset(App.Layout.itemSpacingSmall)
            make.right.equalTo(forgotPasswordView)
            make.bottom.equalTo(forgotPasswordView)
        }
    }

    private func setupBIGroupLabel() {
        biGroupLabel = UILabel()

        guard let biGroupLabel = biGroupLabel else { return }

        biGroupLabel.font = App.Font.footnote
        biGroupLabel.textColor = App.Color.slateGrey

        let format = NSLocalizedString("bi_group_2017", comment: "") as NSString
        let biGroupText = NSString(string: "").appendingFormat(format, Date().year)
        biGroupLabel.text = biGroupText as String

        addSubview(biGroupLabel)
        biGroupLabel.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }

            make.centerX.equalTo(self)
            make.bottom.equalTo(self).inset(App.Layout.itemSpacingMedium)
        }
    }

    // MARK: - MaskedTextFieldDelegateListener

    open func textField(_ textField: UITextField,
                        didFillMandatoryCharacters complete: Bool,
                        didExtractValue value: String) { }

}
