//
//  NotificationHeaderView.swift
//  Life
//
//  Created by Shyngys Kassymov on 17.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import SnapKit
import Material

class NotificationHeaderView: ImageTextView {

    private(set) var closeButton: FlatButton?

    override init(image: UIImage?, title: String?, subtitle: String?) {
        super.init(image: image, title: title, subtitle: subtitle)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI

    private func setupUI() {
        let insets = UIEdgeInsets.init(
            top: 0,
            left: App.Layout.sideOffset,
            bottom: 0,
            right: 0)
        stackView?.insets = insets

        dividerView?.isHidden = false
        dividerLeftOffset = App.Layout.sideOffset
        dividerRightOffset = App.Layout.sideOffset

        titleLabel?.font = App.Font.headline
        subtitleLabel?.isHidden = true

        imageView?.isHidden = true

        closeButton = FlatButton()
        closeButton?.image = #imageLiteral(resourceName: "close-circle-dark")
        closeButton?.contentMode = .scaleAspectFit
        closeButton?.imageView?.contentMode = .scaleAspectFit
        closeButton?.imageEdgeInsets = .init(top: 0, left: 24, bottom: 0, right: 24)
        closeButton?.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 68, height: 50))
        }

        guard let closeButton = closeButton else { return }

        stackView?.stackView?.addArrangedSubview(closeButton)
    }

}
