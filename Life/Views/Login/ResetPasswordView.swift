//
//  ResetPasswordView.swift
//  Life
//
//  Created by Shyngys Kassymov on 11.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import DynamicColor
import Material
import SnapKit

class ResetPasswordView: UIView {

    private(set) var headerView: GradientView?
    private(set) var headerImageView: UIImageView?
    private(set) var newPasswordField: TextField?
    private(set) var newPasswordRepeatField: TextField?
    private(set) var changeButton: Button?
    private(set) var biGroupLabel: UILabel?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupHeaderView()
        setupNewPasswordField()
        setupRepeatNewPasswordField()
        setupLoginButton()
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

    private func setupNewPasswordField() {
        newPasswordField = TextField(frame: .zero)
        newPasswordField?.placeholder = NSLocalizedString("new_password", comment: "")
        newPasswordField?.clearButtonMode = .whileEditing
        newPasswordField?.visibilityIconButton?.tintColor = App.Color.azure
        newPasswordField?.isVisibilityIconButtonEnabled = true

        guard let headerView = headerView,
            let newPasswordField = newPasswordField else {
            return
        }

        addSubview(newPasswordField)
        newPasswordField.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }

            make.top.equalTo(headerView.snp.bottom).offset(App.Layout.itemSpacingMedium * 2)
            make.left.equalTo(self).inset(App.Layout.sideOffset)
            make.right.equalTo(self).inset(App.Layout.sideOffset)
        }
    }

    private func setupRepeatNewPasswordField() {
        newPasswordRepeatField = TextField(frame: .zero)
        newPasswordRepeatField?.placeholder = NSLocalizedString("new_password_repeat", comment: "")
        newPasswordRepeatField?.clearButtonMode = .whileEditing
        newPasswordRepeatField?.visibilityIconButton?.tintColor = App.Color.azure
        newPasswordRepeatField?.isVisibilityIconButtonEnabled = true

        guard let newPasswordRepeatField = newPasswordRepeatField,
            let newPasswordField = newPasswordField else {
            return
        }

        addSubview(newPasswordRepeatField)
        newPasswordRepeatField.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }

            make.top.equalTo(newPasswordField.snp.bottom).offset(App.Layout.itemSpacingMedium)
            make.left.equalTo(self).inset(App.Layout.sideOffset)
            make.right.equalTo(self).inset(App.Layout.sideOffset)
        }
    }

    private func setupLoginButton() {
        changeButton = Button(title: NSLocalizedString("change", comment: "").uppercased())

        guard let newPasswordRepeatField = newPasswordRepeatField,
            let changeButton = changeButton else {
            return
        }

        addSubview(changeButton)
        changeButton.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }

            make.top.equalTo(newPasswordRepeatField.snp.bottom).offset(App.Layout.itemSpacingBig)
            make.left.equalTo(self).inset(App.Layout.sideOffset)
            make.right.equalTo(self).inset(App.Layout.sideOffset)
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

}
