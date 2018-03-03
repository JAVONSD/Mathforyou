//
//  MenuHeaderButton.swift
//  Life
//
//  Created by Shyngys Kassymov on 03.03.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material
import SnapKit

class MenuHeaderButton: FlatButton {

    private(set) lazy var employeeImageView = UIImageView()
    private(set) lazy var textContainerView = UIView()
    private(set) lazy var textLabel = UILabel()
    private(set) lazy var subtitleLabel = UILabel()
    private(set) lazy var accessoryButton = UIButton()
    private(set) lazy var disclosureImageView = UIImageView()
    private(set) lazy var separatorView = UIView()

    var imageSize: CGSize = CGSize(width: 56, height: 56) {
        didSet {
            employeeImageView.snp.remakeConstraints { (make) in
                make.left.equalTo(self).inset(App.Layout.sideOffset)
                make.centerY.equalTo(self)
                make.size.equalTo(imageSize)
            }
        }
    }

    var separatorLeftOffset: CGFloat = 80 {
        didSet {
            separatorView.snp.remakeConstraints { (make) in
                make.left.equalTo(self).inset(separatorLeftOffset)
                make.bottom.equalTo(self)
                make.right.equalTo(self).inset(separatorRightOffset)
                make.height.equalTo(0.5)
            }
        }
    }
    var separatorRightOffset: CGFloat = 0 {
        didSet {
            separatorView.snp.remakeConstraints { (make) in
                make.left.equalTo(self).inset(separatorLeftOffset)
                make.bottom.equalTo(self)
                make.right.equalTo(self).inset(separatorRightOffset)
                make.height.equalTo(0.5)
            }
        }
    }

    override func prepare() {
        super.prepare()

        setupUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        textLabel.preferredMaxLayoutWidth = textLabel.frame.size.width
        subtitleLabel.preferredMaxLayoutWidth = subtitleLabel.frame.size.width
    }

    // MARK: - UI

    private func setupUI() {
        backgroundColor = .clear

        setupEmployeeImageView()
        setupTextContainerView()
        setupAccessoryButton()
        setupDisclosureImageView()
    }

    private func setupEmployeeImageView() {
        employeeImageView.backgroundColor = App.Color.paleGreyTwo
        employeeImageView.layer.cornerRadius = App.Layout.cornerRadiusSmall
        employeeImageView.layer.masksToBounds = true
        employeeImageView.backgroundColor = UIColor(hexString: "#d8d8d8")
        employeeImageView.contentMode = .scaleAspectFill
        addSubview(employeeImageView)
        employeeImageView.snp.makeConstraints { (make) in
            make.left.equalTo(self).inset(App.Layout.sideOffset)
            make.centerY.equalTo(self)
            make.size.equalTo(CGSize(width: 56, height: 56))
        }
    }

    private func setupTextContainerView() {
        textContainerView.isUserInteractionEnabled = false
        addSubview(textContainerView)
        textContainerView.snp.makeConstraints { (make) in
            make.top.equalTo(self).inset(32)
            make.left.equalTo(self.employeeImageView.snp.right).offset(App.Layout.itemSpacingMedium)
            make.bottom.equalTo(self).inset(30)
        }

        setupTitleLabel()
        setupSubtitleLabel()
    }

    private func setupTitleLabel() {
        textLabel.font = App.Font.headline
        textLabel.textColor = UIColor.black
        textLabel.lineBreakMode = .byWordWrapping
        textLabel.numberOfLines = 0
        textContainerView.addSubview(textLabel)
        textLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.textContainerView)
            make.left.equalTo(self.textContainerView)
            make.right.equalTo(self.textContainerView)
        }
    }

    private func setupSubtitleLabel() {
        subtitleLabel.font = App.Font.caption
        subtitleLabel.textColor = App.Color.steel
        subtitleLabel.lineBreakMode = .byWordWrapping
        subtitleLabel.numberOfLines = 0
        textContainerView.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.textLabel.snp.bottom).offset(4)
            make.left.equalTo(self.textContainerView)
            make.right.equalTo(self.textContainerView)
            make.bottom.equalTo(self.textContainerView)
        }
    }

    private func setupAccessoryButton() {
        accessoryButton.backgroundColor = App.Color.paleGreyTwo
        accessoryButton.layer.cornerRadius = App.Layout.cornerRadiusSmall
        accessoryButton.layer.masksToBounds = true
        accessoryButton.isHidden = true
        addSubview(accessoryButton)
        accessoryButton.snp.makeConstraints { (make) in
            make.left.equalTo(self.textContainerView.snp.right).offset(13)
            make.centerY.equalTo(self)
            make.size.equalTo(CGSize(width: 22, height: 22))
        }
    }

    private func setupDisclosureImageView() {
        disclosureImageView.contentMode = .scaleAspectFit
        disclosureImageView.image = #imageLiteral(resourceName: "chevron_right")
        disclosureImageView.tintColor = App.Color.silver
        addSubview(disclosureImageView)
        disclosureImageView.snp.makeConstraints { (make) in
            make.left.equalTo(self.accessoryButton.snp.right).offset(App.Layout.itemSpacingSmall)
            make.right.equalTo(self).inset(App.Layout.sideOffset)
            make.centerY.equalTo(self)
            make.size.equalTo(CGSize(width: 18, height: 18))
        }
    }

}
