//
//  TasksAndRequestsCell.swift
//  Life
//
//  Created by Shyngys Kassymov on 21.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material
import SnapKit

class TasksAndRequetsCell: ImageTextTableViewCell {

    private(set) lazy var detailView = EmployeeDetailView(frame: .zero)

    override func prepare() {
        super.prepare()

        view?.imageView?.isHidden = true

        setTitle(font: App.Font.body)
        setSubtitle(font: App.Font.caption)
        set(insets: .init(
            top: App.Layout.itemSpacingMedium,
            left: App.Layout.sideOffset,
            bottom: App.Layout.itemSpacingMedium,
            right: 0)
        )
        setDivider(leftInset: App.Layout.sideOffset)

        detailView.label.isHidden = true
        view?.stackView?.stackView?.addArrangedSubview(detailView)
    }

}
