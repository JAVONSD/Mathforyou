//
//  EmployeeCell.swift
//  Life
//
//  Created by Shyngys Kassymov on 16.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material
import SnapKit

class EmployeeCell: ImageTextTableViewCell {

    private(set) lazy var detailView = EmployeeDetailView(frame: .zero)

    override func prepare() {
        super.prepare()

        set(imageSize: CGSize(width: 40, height: 40))
        set(imageRadius: App.Layout.cornerRadiusSmall)
        setImageText(spacing: App.Layout.itemSpacingMedium)

        setTitle(font: App.Font.body)

        setSubtitle(font: App.Font.caption)
        set(insets: .init(
            top: App.Layout.itemSpacingMedium,
            left: App.Layout.sideOffset,
            bottom: App.Layout.itemSpacingMedium,
            right: 0)
        )
        setDivider(leftInset: 80)

        view?.stackView?.stackView?.addArrangedSubview(detailView)
    }

}
