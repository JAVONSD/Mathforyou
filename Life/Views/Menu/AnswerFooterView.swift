//
//  AnswerFooterView.swift
//  Life
//
//  Created by Shyngys Kassymov on 07.03.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material
import SnapKit

class AnswerFooterView: UIView {

    private(set) lazy var textField = TextView()
    private(set) lazy var sendButton = Button(
        title: NSLocalizedString("send", comment: "").uppercased()
    )

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI

    private func setupUI() {
        setupTextField()
        setupSendButton()
    }

    private func setupTextField() {
        textField.backgroundColor = App.Color.paleGrey
        textField.layer.borderColor = App.Color.coolGrey.cgColor
        textField.layer.borderWidth = 0.5
        textField.layer.cornerRadius = App.Layout.cornerRadius
        textField.layer.masksToBounds = true
        textField.placeholder = NSLocalizedString("write_answer", comment: "")
        textField.textContainerInsets = EdgeInsets(
            top: 14,
            left: App.Layout.itemSpacingMedium,
            bottom: 14,
            right: App.Layout.itemSpacingMedium
        )
        addSubview(textField)
        textField.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(App.Layout.itemSpacingBig)
            make.left.equalTo(self).inset(App.Layout.sideOffset)
            make.right.equalTo(self).inset(App.Layout.sideOffset)
            make.height.equalTo(144)
        }
    }

    private func setupSendButton() {
        addSubview(sendButton)
        sendButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.textField.snp.bottom).offset(App.Layout.itemSpacingMedium)
            make.left.equalTo(self).inset(App.Layout.sideOffset)
            make.bottom.equalTo(self).inset(App.Layout.sideOffset)
            make.right.equalTo(self).inset(App.Layout.sideOffset)
        }
    }

}
