//
//  ForgotPasswordView.swift
//  Life
//
//  Created by Shyngys Kassymov on 11.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material
import SnapKit

class ForgotPasswordView: UIView, UITextFieldDelegate, MaskedTextFieldDelegateListener {

    private(set) var backgroundView: GradientView?
    private(set) var closeButton: FlatButton?
    private(set) var titleLabel: UILabel?
    private(set) var descriptionLabel: UILabel?
    private(set) var phoneField: TextField?
    private(set) var sendButton: Button?
    private(set) var biGroupLabel: UILabel?

    private var maskFormatter: MaskedTextFieldDelegate!

    var didTapClose: (() -> Void)?

    init(login: String) {
        super.init(frame: .zero)

        setupBackgroundView()
        setupCloseButton()
        setupTitleLabel()
        setupDescriptionLabel()
        setupPhoneField(login: login)
        setupSendButton()
        setupBIGroupLabel()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if let descriptionLabel = descriptionLabel {
            descriptionLabel.preferredMaxLayoutWidth = descriptionLabel.frame.size.width
        }
    }

    // MARK: - Actions

    @objc
    private func handleCloseButton() {
        if let didTapClose = didTapClose {
            didTapClose()
        }
    }

    // MARK: - UI

    private func setupBackgroundView() {
        backgroundView = GradientView()

        guard let backgroundView = backgroundView else { return }

        backgroundView.makeHorizontal()
        backgroundView.setGradient(colors: App.Color.blueGradient)

        backgroundView.layer.shadowColor = App.Color.black12.cgColor
        backgroundView.layer.shadowOffset = CGSize(width: 0, height: 6)
        backgroundView.layer.shadowRadius = 6
        backgroundView.layer.shadowOpacity = 1

        addSubview(backgroundView)
        backgroundView.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }
            make.edges.equalTo(self)
        }
    }

    private func setupCloseButton() {
        closeButton = FlatButton(image: #imageLiteral(resourceName: "close-circle"))
        closeButton?.imageView?.contentMode = .scaleAspectFit

        guard let closeButton = closeButton else { return }

        closeButton.addTarget(self, action: #selector(handleCloseButton), for: .touchUpInside)

        addSubview(closeButton)
        closeButton.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }
            make.top.equalTo(self).inset(App.Layout.sideOffset * 2)
            make.left.equalTo(self).inset(App.Layout.sideOffset)
        }
    }

    private func setupTitleLabel() {
        titleLabel = UILabel()

        guard let closeButton = closeButton,
            let titleLabel = titleLabel else {
            return
        }

        titleLabel.font = App.Font.headline
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.text = NSLocalizedString("cant_login_title", comment: "")

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }

            make.top.equalTo(closeButton.snp.bottom).offset(App.Layout.sideOffset)
            make.left.equalTo(self).inset(App.Layout.sideOffset)
            make.right.equalTo(self).inset(App.Layout.sideOffset)
        }
    }

    private func setupDescriptionLabel() {
        descriptionLabel = UILabel()

        guard let titleLabel = titleLabel,
            let descriptionLabel = descriptionLabel else {
            return
        }

        descriptionLabel.font = App.Font.caption
        descriptionLabel.lineBreakMode = .byWordWrapping
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        descriptionLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        descriptionLabel.text = NSLocalizedString("cant_login_descr", comment: "")

        addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }

            make.top.equalTo(titleLabel.snp.bottom).offset(App.Layout.itemSpacingSmall)
            make.left.equalTo(self).inset(App.Layout.sideOffset)
            make.right.equalTo(self).inset(App.Layout.sideOffset)
        }
    }

    private func setupPhoneField(login: String) {
//        maskFormatter = MaskedTextFieldDelegate(format: "{+7} ([000]) [000] [00] [00]")
//        maskFormatter.listener = self

        phoneField = TextField(frame: .zero)
        phoneField?.text = login

        guard let phoneField = phoneField,
            let descriptionLabel = descriptionLabel else {
                return
        }

        phoneField.placeholder = NSLocalizedString("username_or_phone", comment: "")
        phoneField.autocorrectionType = .no
        phoneField.autocapitalizationType = .none
        phoneField.delegate = self

//        phoneField.delegate = maskFormatter
        phoneField.makeLight()

//        maskFormatter.put(text: "+7 ", into: phoneField)

        addSubview(phoneField)
        phoneField.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }

            make.top.equalTo(descriptionLabel.snp.bottom).offset(App.Layout.itemSpacingMedium * 2)
            make.left.equalTo(self).inset(App.Layout.sideOffset)
            make.right.equalTo(self).inset(App.Layout.sideOffset)
        }
    }

    private func setupSendButton() {
        sendButton = Button(title: NSLocalizedString("send", comment: "").uppercased())

        guard let phoneField = phoneField, let sendButton = sendButton else { return }

        addSubview(sendButton)
        sendButton.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }

            make.top.equalTo(phoneField.snp.bottom).offset(App.Layout.itemSpacingBig)
            make.left.equalTo(self).inset(App.Layout.sideOffset)
            make.right.equalTo(self).inset(App.Layout.sideOffset)
        }
    }

    private func setupBIGroupLabel() {
        biGroupLabel = UILabel()

        guard let biGroupLabel = biGroupLabel else { return }

        biGroupLabel.font = App.Font.footnote
        biGroupLabel.textColor = UIColor.white.withAlphaComponent(0.4)

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

    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
