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

class EmployeeHeaderView: ImageTextView {

    private(set) var callButton: FlatButton?

    override init(
        image: UIImage? = nil,
        title: String? = nil,
        subtitle: String? = nil) {
        super.init(image: image, title: title, subtitle: subtitle)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard let stackView = stackView,
            let titleLabel = titleLabel else {
                return
        }

        var width = bounds.size.width
        let insets = stackView.insets.left + stackView.insets.right
        width -= insets
        let itemsCount = CGFloat(stackView.stackView?.arrangedSubviews.count ?? 0)
        let spacing = (stackView.stackView?.spacing ?? 0) * itemsCount
        width -= spacing
        width -= imageSize.width
        width -= 80
        titleLabel.preferredMaxLayoutWidth = width
        titleLabel.lineBreakMode = .byWordWrapping
    }

    // MARK: - UI

    private func setupUI() {
        imageSize = CGSize(width: 72, height: 72)
        dividerLeftOffset = App.Layout.sideOffset
        dividerRightOffset = App.Layout.sideOffset
        dividerView?.isHidden = false

        stackView?.insets = .init(
            top: App.Layout.itemSpacingMedium,
            left: App.Layout.sideOffset,
            bottom: App.Layout.sideOffset,
            right: App.Layout.sideOffset
        )

        setupCallButton()
    }

    private func setupCallButton() {
        callButton = FlatButton()

        guard let callButton = callButton else {
            return
        }

        callButton.image = #imageLiteral(resourceName: "phone-inactive")
        callButton.tintColor = App.Color.azure
        callButton.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 80, height: 80))
        }
        callButton.layer.cornerRadius = 40
        callButton.layer.masksToBounds = true
        callButton.imageEdgeInsets = .init(
            top: App.Layout.itemSpacingSmall,
            left: 0,
            bottom: 0,
            right: 0
        )

        stackView?.stackView?.addArrangedSubview(callButton)
    }

}
