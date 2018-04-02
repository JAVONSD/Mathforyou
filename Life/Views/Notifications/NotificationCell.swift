//
//  NotificationCell.swift
//  Life
//
//  Created by Shyngys Kassymov on 17.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Hue
import Material
import SnapKit

class NotificationCell: ImageTextTableViewCell {

    private(set) lazy var detailImageView = UIImageView()

    override func prepare() {
        super.prepare()

        view?.imageView?.isHidden = true

        setTitle(font: App.Font.body)
        setSubtitle(font: App.Font.caption)
        set(insets: .init(
            top: App.Layout.itemSpacingMedium,
            left: App.Layout.sideOffset,
            bottom: App.Layout.itemSpacingMedium,
            right: App.Layout.sideOffset)
        )
        setDivider(leftInset: App.Layout.sideOffset)
        setDivider(rightInset: App.Layout.sideOffset)

        detailImageView.backgroundColor = UIColor(hex: "#d8d8d8")
        detailImageView.contentMode = .scaleAspectFill
        detailImageView.layer.cornerRadius = App.Layout.cornerRadiusSmall
        detailImageView.layer.masksToBounds = true
        detailImageView.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 32, height: 32))
        }
        detailImageView.isHidden = true
        view?.stackView?.stackView?.addArrangedSubview(detailImageView)
    }

}
