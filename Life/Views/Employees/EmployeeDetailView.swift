//
//  EmployeeDetailView.swift
//  Life
//
//  Created by Shyngys Kassymov on 16.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import SnapKit

class EmployeeDetailView: UIView {

    private(set) lazy var label = UILabel()
    private(set) lazy var chevronImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI

    private func setupUI() {
        backgroundColor = .clear

        setupLabel()
        setupChevron()
    }

    private func setupLabel() {
        label.backgroundColor = App.Color.paleGreyTwo
        label.layer.cornerRadius = App.Layout.cornerRadiusSmall
        label.layer.masksToBounds = true
        addSubview(label)
        label.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }
            make.centerY.equalTo(self)
            make.left.equalTo(self).inset(13)
            make.size.equalTo(CGSize(width: 22, height: 22))
        }
    }

    private func setupChevron() {
        chevronImageView.contentMode = .scaleAspectFit
        chevronImageView.image = #imageLiteral(resourceName: "chevron_right")
        chevronImageView.tintColor = App.Color.silver
        addSubview(chevronImageView)
        chevronImageView.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }
            make.centerY.equalTo(self)
            make.left.equalTo(self.label.snp.right).offset(App.Layout.itemSpacingSmall)
            make.right.equalTo(self).inset(App.Layout.sideOffset)
            make.size.equalTo(CGSize(width: 18, height: 18))
        }
    }

}
