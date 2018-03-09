//
//  VideoAnswerFooterView.swift
//  Life
//
//  Created by Shyngys Kassymov on 07.03.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material
import SnapKit

class VideoAnswerFooterView: UIView {

    private(set) lazy var chooseVideoButton = FlatButton(
        title: NSLocalizedString("add_video_answer", comment: ""),
        titleColor: App.Color.steel
    )
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
        setupChooseVideoButton()
        setupSendButton()
    }

    private func setupChooseVideoButton() {
        chooseVideoButton.image = #imageLiteral(resourceName: "ic-insert-photo")
        chooseVideoButton.tintColor = App.Color.coolGrey
        chooseVideoButton.titleEdgeInsets = .init(top: 0, left: 8, bottom: 0, right: 0)
        chooseVideoButton.titleLabel?.font = App.Font.caption
        chooseVideoButton.titleLabel?.textColor = App.Color.steel
        chooseVideoButton.layer.cornerRadius = App.Layout.cornerRadius
        chooseVideoButton.layer.masksToBounds = true
        chooseVideoButton.layer.borderColor = App.Color.coolGrey.cgColor
        chooseVideoButton.layer.borderWidth = 0.5
        addSubview(chooseVideoButton)
        chooseVideoButton.snp.makeConstraints { (make) in
            make.top.equalTo(self).inset(App.Layout.sideOffset)
            make.left.equalTo(self).inset(App.Layout.sideOffset)
            make.right.equalTo(self).inset(App.Layout.sideOffset)
            make.height.equalTo(72)
        }
    }

    private func setupSendButton() {
        addSubview(sendButton)
        sendButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.chooseVideoButton.snp.bottom).offset(App.Layout.itemSpacingMedium)
            make.left.equalTo(self).inset(App.Layout.sideOffset)
            make.bottom.equalTo(self).inset(App.Layout.sideOffset)
            make.right.equalTo(self).inset(App.Layout.sideOffset)
        }
    }

}
