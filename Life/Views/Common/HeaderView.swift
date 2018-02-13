//
//  HeaderView.swift
//  Life
//
//  Created by Shyngys Kassymov on 13.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import SnapKit

class HeaderView: UITableViewHeaderFooterView {

    private(set) var titleLabel: UILabel?

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

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
            make.top.equalTo(self.contentView).inset(insets.top)
            make.left.equalTo(self.contentView).inset(insets.left)
            make.bottom.equalTo(self.contentView).inset(insets.bottom)
            make.right.equalTo(self.contentView).inset(insets.right)
        }
    }

    // MARK: - UI

    private func setupUI() {
        titleLabel = UILabel()
        titleLabel?.font = App.Font.subheadAlts
        titleLabel?.textColor = .black

        guard let titleLabel = titleLabel else { return }

        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }
            make.top.equalTo(self.contentView).inset(App.Layout.itemSpacingSmall)
            make.left.equalTo(self.contentView).inset(App.Layout.sideOffset)
            make.bottom.equalTo(self.contentView)
            make.right.equalTo(self.contentView).inset(App.Layout.sideOffset)
        }
    }

}
