//
//  CheckboxCell.swift
//  Life
//
//  Created by Shyngys Kassymov on 07.03.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material

class CheckboxCell: TableViewCell {

    private(set) lazy var checkboxButton = UIButton()
    private(set) lazy var titleLabel = UILabel()

    override func prepare() {
        super.prepare()

        setupUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        titleLabel.preferredMaxLayoutWidth = titleLabel.frame.size.width
    }

    // MARK: - UI

    private func setupUI() {
        setupCheckboxButton()
        setupTitleLabel()
    }

    private func setupCheckboxButton() {
        checkboxButton.setImage(#imageLiteral(resourceName: "checkbox_empty"), for: .normal)
        checkboxButton.setImage(#imageLiteral(resourceName: "checkbox_tick"), for: .selected)
        checkboxButton.setImage(#imageLiteral(resourceName: "checkbox_tick"), for: .highlighted)
        checkboxButton.tintColor = App.Color.coolGrey
        checkboxButton.isUserInteractionEnabled = false
        contentView.addSubview(checkboxButton)
        checkboxButton.snp.makeConstraints { (make) in
            make.left.equalTo(self.contentView).inset(App.Layout.sideOffset)
            make.centerY.equalTo(self.contentView)
        }
    }

    private func setupTitleLabel() {
        titleLabel.font = App.Font.body
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .black
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.contentView).offset(App.Layout.itemSpacingSmall)
            make.left.equalTo(self.checkboxButton.snp.right).offset(App.Layout.itemSpacingMedium)
            make.bottom.equalTo(self.contentView).offset(App.Layout.itemSpacingSmall)
            make.right.equalTo(self.contentView).inset(App.Layout.sideOffset)
        }
    }

}
