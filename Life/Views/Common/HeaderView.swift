//
//  HeaderView.swift
//  Life
//
//  Created by Shyngys Kassymov on 13.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import SnapKit

class HeaderView: UIView {

    private(set) var titleLabel: UILabel?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods

    public func set(insets: UIEdgeInsets) {
        guard let titleLabel = titleLabel else { return }

        titleLabel.snp.remakeConstraints { [weak self] (make) in
            guard let `self` = self else { return }
            make.top.equalTo(self).inset(insets.top)
            make.left.equalTo(self).inset(insets.left)
            make.bottom.equalTo(self).inset(insets.bottom)
            make.right.equalTo(self).inset(insets.right)
        }
    }

    // MARK: - UI

    private func setupUI() {
        backgroundColor = .clear

        titleLabel = UILabel()
        titleLabel?.font = App.Font.subheadAlts
        titleLabel?.textColor = .black

        guard let titleLabel = titleLabel else { return }

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }
            make.top.equalTo(self).inset(App.Layout.itemSpacingSmall)
            make.left.equalTo(self).inset(App.Layout.sideOffset)
            make.bottom.equalTo(self)
            make.right.equalTo(self).inset(App.Layout.sideOffset)
        }
    }

}
