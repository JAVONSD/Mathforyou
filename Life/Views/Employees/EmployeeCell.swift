//
//  EmployeeCell.swift
//  Life
//
//  Created by Shyngys Kassymov on 16.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Hue
import Material
import SnapKit

class EmployeeCell: TableViewCell {

    private(set) lazy var employeeImageView = UIImageView()
    private(set) lazy var textContainerView = UIView()
    private(set) lazy var titleLabel = UILabel()
    private(set) lazy var subtitleLabel = UILabel()
    private(set) lazy var accessoryButton = UIButton()
    private(set) lazy var disclosureImageView = UIImageView()
    private(set) lazy var separatorView = UIView()

    var imageSize: CGSize = CGSize(width: 40, height: 40) {
        didSet {
            employeeImageView.snp.remakeConstraints { (make) in
                make.left.equalTo(self.contentView).inset(App.Layout.sideOffset)
                make.centerY.equalTo(self.contentView)
                make.size.equalTo(imageSize)
            }
        }
    }

    var separatorLeftOffset: CGFloat = 80 {
        didSet {
            separatorView.snp.remakeConstraints { (make) in
                make.left.equalTo(self.contentView).inset(separatorLeftOffset)
                make.bottom.equalTo(self.contentView)
                make.right.equalTo(self.contentView).inset(separatorRightOffset)
                make.height.equalTo(0.5)
            }
        }
    }
    var separatorRightOffset: CGFloat = 0 {
        didSet {
            separatorView.snp.remakeConstraints { (make) in
                make.left.equalTo(self.contentView).inset(separatorLeftOffset)
                make.bottom.equalTo(self.contentView)
                make.right.equalTo(self.contentView).inset(separatorRightOffset)
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

        titleLabel.preferredMaxLayoutWidth = titleLabel.frame.size.width
        subtitleLabel.preferredMaxLayoutWidth = subtitleLabel.frame.size.width
    }

    // MARK: - UI

    private func setupUI() {
        backgroundColor = .clear
        backgroundView = nil
        contentView.backgroundColor = .clear

        setupEmployeeImageView()
        setupTextContainerView()
        setupAccessoryButton()
        setupDisclosureImageView()
        setupSeparatorView()
    }

    private func setupEmployeeImageView() {
        employeeImageView.backgroundColor = App.Color.paleGreyTwo
        employeeImageView.layer.cornerRadius = App.Layout.cornerRadiusSmall
        employeeImageView.layer.masksToBounds = true
        employeeImageView.backgroundColor = UIColor(hex: "#d8d8d8")
        employeeImageView.contentMode = .scaleAspectFill
        contentView.addSubview(employeeImageView)
        employeeImageView.snp.makeConstraints { (make) in
            make.left.equalTo(self.contentView).inset(App.Layout.sideOffset)
            make.centerY.equalTo(self.contentView)
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
    }

    private func setupTextContainerView() {
        contentView.addSubview(textContainerView)
        textContainerView.snp.makeConstraints { (make) in
            make.top.equalTo(self.contentView).inset(19)
            make.left.equalTo(self.employeeImageView.snp.right).offset(App.Layout.itemSpacingMedium)
            make.bottom.equalTo(self.contentView).inset(19)
        }

        setupTitleLabel()
        setupSubtitleLabel()
    }

    private func setupTitleLabel() {
        titleLabel.font = App.Font.body
        titleLabel.textColor = UIColor.black
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        textContainerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
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
            make.top.equalTo(self.titleLabel.snp.bottom)
            make.left.equalTo(self.textContainerView)
            make.right.equalTo(self.textContainerView)
            make.bottom.equalTo(self.textContainerView)
        }
    }

    private func setupAccessoryButton() {
        accessoryButton.backgroundColor = App.Color.paleGreyTwo
        accessoryButton.layer.cornerRadius = App.Layout.cornerRadiusSmall
        accessoryButton.layer.masksToBounds = true
        contentView.addSubview(accessoryButton)
        accessoryButton.snp.makeConstraints { (make) in
            make.left.equalTo(self.textContainerView.snp.right).offset(13)
            make.centerY.equalTo(self.contentView)
            make.size.equalTo(CGSize(width: 22, height: 22))
        }
    }

    private func setupDisclosureImageView() {
        disclosureImageView.contentMode = .scaleAspectFit
        disclosureImageView.image = #imageLiteral(resourceName: "chevron_right")
        disclosureImageView.tintColor = App.Color.silver
        contentView.addSubview(disclosureImageView)
        disclosureImageView.snp.makeConstraints { (make) in
            make.left.equalTo(self.accessoryButton.snp.right).offset(App.Layout.itemSpacingSmall)
            make.right.equalTo(self.contentView).inset(App.Layout.sideOffset)
            make.centerY.equalTo(self.contentView)
            make.size.equalTo(CGSize(width: 18, height: 18))
        }
    }

    private func setupSeparatorView() {
        separatorView.backgroundColor = App.Color.coolGrey
        contentView.addSubview(separatorView)
        separatorView.snp.makeConstraints { (make) in
            make.left.equalTo(self.contentView).inset(80)
            make.bottom.equalTo(self.contentView)
            make.right.equalTo(self.contentView)
            make.height.equalTo(0.5)
        }
    }

}
