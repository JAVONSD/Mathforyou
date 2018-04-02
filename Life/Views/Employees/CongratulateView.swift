//
//  CongratulateView.swift
//  Life
//
//  Created by Shyngys Kassymov on 02.04.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material
import SnapKit

class CongratulateView: UIView {

    private(set) lazy var headerView = NotificationHeaderView(
        image: nil,
        title: NSLocalizedString("congratulate", comment: ""),
        subtitle: NSLocalizedString("with_birthday", comment: "")
    )
    private(set) lazy var textView = TextView()
    private(set) lazy var sendButton = Button(title: NSLocalizedString("send_congratulation", comment: ""))

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI

    private func setupUI() {
        setupHeaderView()
        setupTextView()
        setupSendButton()
    }

    private func setupHeaderView() {
        let insets = UIEdgeInsets.init(
            top: App.Layout.itemSpacingMedium,
            left: App.Layout.sideOffset,
            bottom: App.Layout.itemSpacingMedium,
            right: 0)
        headerView.stackView?.insets = insets
        headerView.titleLabel?.font = App.Font.headline
        headerView.subtitleLabel?.isHidden = false
        headerView.imageView?.isHidden = false
        headerView.imageSize = CGSize(width: 50, height: 50)
        headerView.imageView?.clipsToBounds = true

        addSubview(headerView)
        headerView.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.equalTo(self)
            make.right.equalTo(self)
        }
    }

    private func setupTextView() {
        textView.backgroundColor = App.Color.paleGrey
        textView.layer.borderColor = App.Color.coolGrey.cgColor
        textView.layer.borderWidth = 0.5
        textView.layer.cornerRadius = App.Layout.cornerRadius
        textView.layer.masksToBounds = true
        textView.placeholder = NSLocalizedString("congratulation_text", comment: "")
        textView.textContainerInsets = EdgeInsets(
            top: 14,
            left: App.Layout.itemSpacingMedium,
            bottom: 14,
            right: App.Layout.itemSpacingMedium
        )
        addSubview(textView)
        textView.snp.makeConstraints { (make) in
            make.top.equalTo(self.headerView.snp.bottom).offset(App.Layout.itemSpacingBig)
            make.left.equalTo(self).inset(App.Layout.sideOffset)
            make.right.equalTo(self).inset(App.Layout.sideOffset)
            make.height.equalTo(141)
        }
    }

    private func setupSendButton() {
        addSubview(sendButton)
        sendButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.textView.snp.bottom).offset(App.Layout.itemSpacingMedium)
            make.left.equalTo(self).inset(App.Layout.sideOffset)
            make.bottom.equalTo(self).inset(App.Layout.sideOffset)
            make.right.equalTo(self).inset(App.Layout.sideOffset)
        }
    }

}
