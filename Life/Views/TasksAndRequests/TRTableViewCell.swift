//
//  TRTableViewCell.swift
//  Life
//
//  Created by Shyngys Kassymov on 27.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material
import SnapKit

class TRTableViewCell: TableViewCell {

    private(set) lazy var titleLabel = UILabel()
    private(set) lazy var subtitleLabel = UILabel()
    private(set) lazy var disclosureView = UIImageView()
    private(set) lazy var separatorView = UIView()

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
        backgroundColor = .white

        setupTitleLabel()
        setupSubtitleLabel()
        setupDisclosureView()
        setupSeparatorView()
    }

    private func setupTitleLabel() {
        titleLabel.font = App.Font.body
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .black
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.contentView).inset(19)
            make.left.equalTo(self.contentView).inset(App.Layout.sideOffset)
        }
    }

    private func setupSubtitleLabel() {
        subtitleLabel.font = App.Font.caption
        subtitleLabel.lineBreakMode = .byWordWrapping
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textColor = App.Color.steel
        contentView.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.titleLabel.snp.bottom)
            make.left.equalTo(self.contentView).inset(App.Layout.sideOffset)
        }
    }

    private func setupDisclosureView() {
        disclosureView.contentMode = .scaleAspectFit
        disclosureView.image = #imageLiteral(resourceName: "chevron_right")
        disclosureView.tintColor = App.Color.silver
        contentView.addSubview(disclosureView)
        disclosureView.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.left.equalTo(self.titleLabel.snp.right).offset(App.Layout.itemSpacingMedium)
            make.left.equalTo(self.subtitleLabel.snp.right).offset(App.Layout.itemSpacingMedium)
            make.right.equalTo(self).inset(App.Layout.sideOffset)
            make.size.equalTo(CGSize(width: 18, height: 18))
        }
    }

    private func setupSeparatorView() {
        separatorView.backgroundColor = App.Color.coolGrey
        contentView.addSubview(separatorView)
        separatorView.snp.makeConstraints { (make) in
            make.top.equalTo(self.subtitleLabel.snp.bottom).offset(19)
            make.left.equalTo(self.contentView).inset(App.Layout.sideOffset)
            make.bottom.equalTo(self.contentView)
            make.right.equalTo(self.contentView)
            make.height.equalTo(0.5)
        }
    }

}
