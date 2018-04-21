//
//  EmployeeHeaderView.swift
//  Life
//
//  Created by Shyngys Kassymov on 21.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material
import SnapKit

class EmployeeHeaderView: UIView {

    private(set) lazy var imageView = UIImageView()
    private(set) lazy var titleLabel = UILabel()
    private(set) lazy var callButton = FlatButton()
    private(set) lazy var dividerView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        titleLabel.preferredMaxLayoutWidth = titleLabel.frame.size.width
    }

    // MARK: - UI

    private func setupUI() {
        setupImageView()
        setupTitleLabel()
        setupCallButton()
        setupDividerView()
    }

    private func setupImageView() {
        imageView.backgroundColor = UIColor(hex: "#d8d8d8")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = App.Layout.cornerRadius
        imageView.layer.masksToBounds = true
        addSubview(imageView)
        imageView.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }
            make.top.equalTo(self).inset(App.Layout.itemSpacingMedium)
            make.left.equalTo(self).inset(App.Layout.sideOffset)
            make.bottom.equalTo(self).inset(App.Layout.sideOffset)
            make.size.equalTo(CGSize(width: 72, height: 72))
        }
    }

    private func setupTitleLabel() {
        titleLabel.font = App.Font.headline
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .black
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }
            make.left.equalTo(self.imageView.snp.right).offset(App.Layout.sideOffset)
            make.centerY.equalTo(self.imageView)
        }
    }

    private func setupCallButton() {
        callButton.image = #imageLiteral(resourceName: "phone-inactive")
        callButton.tintColor = App.Color.azure
        callButton.layer.cornerRadius = 40
        callButton.layer.masksToBounds = true
        addSubview(callButton)
        callButton.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }
            make.left.equalTo(self.titleLabel.snp.right).offset(App.Layout.itemSpacingSmall)
            make.right.equalTo(self).inset(App.Layout.sideOffset)
            make.size.equalTo(CGSize(width: 80, height: 80))
            make.centerY.equalTo(self)
        }
    }

    private func setupDividerView() {
        dividerView.backgroundColor = App.Color.coolGrey
        addSubview(dividerView)
        dividerView.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }
            make.left.equalTo(self).inset(App.Layout.sideOffset)
            make.bottom.equalTo(self)
            make.right.equalTo(self).inset(App.Layout.sideOffset)
            make.height.equalTo(0.5)
        }
    }

}
