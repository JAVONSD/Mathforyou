//
//  SuggestionFormView.swift
//  Life
//
//  Created by Shyngys Kassymov on 23.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material
import SnapKit

class SuggestionFormView: UIView, UITextFieldDelegate {

    private(set) lazy var headerView = NotificationHeaderView(
        image: nil,
        title: NSLocalizedString("new_suggestion", comment: ""),
        subtitle: nil
    )
    private(set) lazy var scrollView = UIScrollView()
    private(set) lazy var contentView = UIView()
    private(set) lazy var topicField = TextField(frame: .zero)
    private(set) lazy var textField = TextView(frame: .zero)
    private(set) lazy var addAttachmentButton = FlatButton(
        title: NSLocalizedString("attach", comment: ""),
        titleColor: UIColor.black
    )
    private(set) lazy var sendButton = Button(
        title: NSLocalizedString("send", comment: "").uppercased()
    )

    var didTapCloseButton: (() -> Void)?
    var didTapAttachmentButton: (() -> Void)?
    var didTapSendButton: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Actions

    @objc
    private func handleCloseButton() {
        if let didTapCloseButton = didTapCloseButton {
            didTapCloseButton()
        }
    }

    @objc
    private func handleAttachmentButton() {
        if let didTapAttachmentButton = didTapAttachmentButton {
            didTapAttachmentButton()
        }
    }

    @objc
    private func handleSendButton() {
        if let didTapSendButton = didTapSendButton {
            didTapSendButton()
        }
    }

    // MARK: - UI

    private func setupUI() {
        setupHeaderView()
        setupScrollView()
    }

    private func setupHeaderView() {
        headerView.closeButton?.addTarget(self, action: #selector(handleCloseButton), for: .touchUpInside)
        addSubview(headerView)
        headerView.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.equalTo(self)
            make.right.equalTo(self)
        }
    }

    private func setupScrollView() {
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(self.headerView.snp.bottom)
            make.left.equalTo(self)
            make.bottom.equalTo(self)
            make.right.equalTo(self)
        }

        setupContentView()
    }

    private func setupContentView() {
        scrollView.addSubview(contentView)
        sendSubview(toBack: scrollView)
        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.scrollView)
            make.width.equalTo(self.scrollView)
        }

        setupTopicField()
        setupTextField()
        setupAddAttachmentButton()
        setupSendButton()
    }

    private func setupTopicField() {
        topicField.delegate = self
        topicField.placeholder = NSLocalizedString("topic", comment: "")
        contentView.addSubview(topicField)
        topicField.snp.makeConstraints { (make) in
            make.top.equalTo(self.contentView).inset(App.Layout.sideOffset)
            make.left.equalTo(self.contentView).inset(App.Layout.sideOffset)
            make.right.equalTo(self.contentView).inset(App.Layout.sideOffset)
        }
    }

    private func setupTextField() {
        textField.backgroundColor = App.Color.paleGrey
        textField.layer.borderColor = App.Color.coolGrey.cgColor
        textField.layer.borderWidth = 0.5
        textField.layer.cornerRadius = App.Layout.cornerRadius
        textField.layer.masksToBounds = true
        textField.placeholder = NSLocalizedString("write_text", comment: "")
        textField.textContainerInsets = EdgeInsets(
            top: 14,
            left: App.Layout.itemSpacingMedium,
            bottom: 14,
            right: App.Layout.itemSpacingMedium
        )
        contentView.addSubview(textField)
        textField.snp.makeConstraints { (make) in
            make.top.equalTo(self.topicField.snp.bottom).offset(App.Layout.itemSpacingBig)
            make.left.equalTo(self.contentView).inset(App.Layout.sideOffset)
            make.right.equalTo(self.contentView).inset(App.Layout.sideOffset)
            make.height.equalTo(144)
        }
    }

    private func setupAddAttachmentButton() {
        addAttachmentButton.image = #imageLiteral(resourceName: "attach")
        addAttachmentButton.tintColor = App.Color.steel
        addAttachmentButton.titleEdgeInsets = .init(top: 0, left: 4, bottom: 0, right: 0)
        addAttachmentButton.titleLabel?.font = App.Font.subheadAlts
        addAttachmentButton.titleLabel?.textColor = .black
        addAttachmentButton.contentHorizontalAlignment = .left
        addAttachmentButton.addTarget(self, action: #selector(handleAttachmentButton), for: .touchUpInside)
        contentView.addSubview(addAttachmentButton)
        addAttachmentButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.textField.snp.bottom).offset(App.Layout.itemSpacingSmall)
            make.left.equalTo(self.contentView).inset(App.Layout.sideOffset)
            make.right.equalTo(self.contentView).inset(App.Layout.sideOffset)
            make.height.equalTo(40)
        }
    }

    private func setupSendButton() {
        sendButton.addTarget(self, action: #selector(handleSendButton), for: .touchUpInside)
        contentView.addSubview(sendButton)
        sendButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.addAttachmentButton.snp.bottom).offset(App.Layout.itemSpacingMedium)
            make.left.equalTo(self.contentView).inset(App.Layout.sideOffset)
            make.bottom.equalTo(self.contentView).inset(App.Layout.sideOffset)
            make.right.equalTo(self.contentView).inset(App.Layout.sideOffset)
        }
    }

    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
