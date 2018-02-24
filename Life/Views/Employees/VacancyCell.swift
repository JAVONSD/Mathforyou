//
//  VacancyCell.swift
//  Life
//
//  Created by Shyngys Kassymov on 24.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material
import SnapKit

class VacancyCell: TableViewCell {

    private(set) lazy var positionLabel = UILabel()
    private(set) lazy var companyLabel = UILabel()
    private(set) lazy var salaryLabel = UILabel()
    private(set) lazy var dividerView = UIView()

    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        positionLabel.preferredMaxLayoutWidth = positionLabel.frame.size.width
        companyLabel.preferredMaxLayoutWidth = companyLabel.frame.size.width
        salaryLabel.preferredMaxLayoutWidth = salaryLabel.frame.size.width
    }

    // MARK: - UI

    private func setupUI() {
        backgroundColor = .clear
        backgroundView = nil
        contentView.backgroundColor = .clear

        setupPositionLabel()
        setupCompanyLabel()
        setupSalaryLabel()
        setupDividerView()
    }

    private func setupPositionLabel() {
        positionLabel.font = App.Font.body
        positionLabel.lineBreakMode = .byWordWrapping
        positionLabel.numberOfLines = 0
        positionLabel.textColor = UIColor.black
        contentView.addSubview(positionLabel)
        positionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.contentView).inset(19)
            make.left.equalTo(self.contentView).inset(App.Layout.sideOffset)
            make.right.equalTo(self.contentView).inset(App.Layout.sideOffset)
        }
    }

    private func setupCompanyLabel() {
        companyLabel.font = App.Font.caption
        companyLabel.lineBreakMode = .byWordWrapping
        companyLabel.numberOfLines = 0
        companyLabel.textColor = App.Color.steel
        contentView.addSubview(companyLabel)
        companyLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.positionLabel.snp.bottom)
            make.left.equalTo(self.contentView).inset(App.Layout.sideOffset)
            make.bottom.equalTo(self.contentView).inset(19)
        }
    }

    private func setupSalaryLabel() {
        salaryLabel.font = App.Font.caption
        salaryLabel.lineBreakMode = .byWordWrapping
        salaryLabel.numberOfLines = 0
        salaryLabel.textAlignment = .right
        salaryLabel.textColor = App.Color.steel
        contentView.addSubview(salaryLabel)
        salaryLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.positionLabel.snp.bottom)
            make.left.equalTo(self.companyLabel.snp.right).offset(App.Layout.itemSpacingSmall)
            make.right.equalTo(self.contentView).inset(App.Layout.sideOffset)
            make.bottom.equalTo(self.contentView).inset(19)
            make.width.equalTo(self.companyLabel.snp.width).multipliedBy(0.5)
        }
    }

    private func setupDividerView() {
        dividerView.backgroundColor = App.Color.coolGrey
        contentView.addSubview(dividerView)
        dividerView.snp.makeConstraints { (make) in
            make.left.equalTo(self.contentView).inset(App.Layout.sideOffset)
            make.right.equalTo(self.contentView).inset(App.Layout.sideOffset)
            make.bottom.equalTo(self.contentView)
            make.height.equalTo(0.5)
        }
    }

}
