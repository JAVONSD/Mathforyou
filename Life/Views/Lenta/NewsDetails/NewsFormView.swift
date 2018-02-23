//
//  NewsFormView.swift
//  Life
//
//  Created by Shyngys Kassymov on 23.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material
import SnapKit

class NewsFormView: UIView, UITextFieldDelegate {

    private(set) lazy var headerView = NotificationHeaderView(
        image: nil,
        title: NSLocalizedString("add_news", comment: ""),
        subtitle: nil
    )
    private(set) lazy var scrollView = UIScrollView()
    private(set) lazy var contentView = UIView()
    private(set) lazy var coverImageButton = FlatButton(
        title: NSLocalizedString("add_cover", comment: ""),
        titleColor: App.Color.steel
    )
    private(set) lazy var attachmentButton = FlatButton()
    private(set) lazy var titleField = TextField(frame: .zero)
    private(set) lazy var textField = TextView(frame: .zero)
    private(set) lazy var tagsField = TextField(frame: .zero)
    private(set) lazy var makeAsHistoryButton = FlatButton(
        title: NSLocalizedString("history_event_to_history", comment: ""),
        titleColor: App.Color.steel
    )
    private(set) lazy var sendButton = Button(
        title: NSLocalizedString("send", comment: "").uppercased()
    )

    var didTapCloseButton: (() -> Void)?
    var didTapCoverImageButton: (() -> Void)?
    var didTapAttachmentButton: (() -> Void)?
    var didTapMakeAsHistoryButton: (() -> Void)?
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
    private func handleCoverImageButton() {
        if let didTapCoverImageButton = didTapCoverImageButton {
            didTapCoverImageButton()
        }
    }

    @objc
    private func handleAttachmentButton() {
        if let didTapAttachmentButton = didTapAttachmentButton {
            didTapAttachmentButton()
        }
    }

    @objc
    private func handleMakeAsHistoryButton() {
        let selected = !makeAsHistoryButton.isSelected
        makeAsHistoryButton.isSelected = selected
        makeAsHistoryButton.tintColor = selected ? App.Color.azure : App.Color.coolGrey

        if let didTapMakeAsHistoryButton = didTapMakeAsHistoryButton {
            didTapMakeAsHistoryButton()
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

        setupCoverImageButton()
        setupAttachmentButton()
        setupTitleField()
        setupTextField()
        setupTagsField()
        setupMakeAsHistoryButton()
        setupSendButton()
    }

    private func setupCoverImageButton() {
        coverImageButton.image = Icon.cm.image
        coverImageButton.tintColor = App.Color.coolGrey
        coverImageButton.titleEdgeInsets = .init(top: 0, left: 8, bottom: 0, right: 0)
        coverImageButton.titleLabel?.font = App.Font.caption
        coverImageButton.titleLabel?.textColor = App.Color.steel
        coverImageButton.layer.cornerRadius = App.Layout.cornerRadius
        coverImageButton.layer.masksToBounds = true
        coverImageButton.layer.borderColor = App.Color.coolGrey.cgColor
        coverImageButton.layer.borderWidth = 0.5
        coverImageButton.addTarget(self, action: #selector(handleCoverImageButton), for: .touchUpInside)
        contentView.addSubview(coverImageButton)
        coverImageButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.contentView).inset(App.Layout.sideOffset)
            make.left.equalTo(self.contentView).inset(App.Layout.sideOffset)
            make.height.equalTo(72)
        }
    }

    private func setupAttachmentButton() {
        attachmentButton.image = #imageLiteral(resourceName: "attach")
        attachmentButton.tintColor = App.Color.coolGrey
        attachmentButton.addTarget(self, action: #selector(handleAttachmentButton), for: .touchUpInside)
        attachmentButton.layer.cornerRadius = App.Layout.cornerRadius
        attachmentButton.layer.masksToBounds = true
        attachmentButton.layer.borderColor = App.Color.coolGrey.cgColor
        attachmentButton.layer.borderWidth = 0.5
        contentView.addSubview(attachmentButton)
        attachmentButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.contentView).inset(App.Layout.sideOffset)
            make.left.equalTo(self.coverImageButton.snp.right).offset(App.Layout.itemSpacingSmall)
            make.right.equalTo(self.contentView).inset(App.Layout.sideOffset)
            make.height.equalTo(72)
            make.width.equalTo(72)
        }
    }

    private func setupTitleField() {
        titleField.delegate = self
        titleField.placeholder = NSLocalizedString("title", comment: "")
        contentView.addSubview(titleField)
        titleField.snp.makeConstraints { (make) in
            make.top.equalTo(self.coverImageButton.snp.bottom).offset(App.Layout.sideOffset)
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
        textField.placeholder = NSLocalizedString("enter_text", comment: "")
        textField.textContainerInsets = EdgeInsets(
            top: 14,
            left: App.Layout.itemSpacingMedium,
            bottom: 14,
            right: App.Layout.itemSpacingMedium
        )
        contentView.addSubview(textField)
        textField.snp.makeConstraints { (make) in
            make.top.equalTo(self.titleField.snp.bottom).offset(App.Layout.itemSpacingMedium)
            make.left.equalTo(self.contentView).inset(App.Layout.sideOffset)
            make.right.equalTo(self.contentView).inset(App.Layout.sideOffset)
            make.height.equalTo(56)
        }
    }

    private func setupTagsField() {
        tagsField.delegate = self
        tagsField.placeholder = NSLocalizedString("tags", comment: "")
        contentView.addSubview(tagsField)
        tagsField.snp.makeConstraints { (make) in
            make.top.equalTo(self.textField.snp.bottom).offset(App.Layout.sideOffset)
            make.left.equalTo(self.contentView).inset(App.Layout.sideOffset)
            make.right.equalTo(self.contentView).inset(App.Layout.sideOffset)
        }
    }

    private func setupMakeAsHistoryButton() {
        makeAsHistoryButton.setImage(#imageLiteral(resourceName: "checkbox_empty"), for: .normal)
        makeAsHistoryButton.setImage(#imageLiteral(resourceName: "checkbox_tick"), for: .selected)
        makeAsHistoryButton.setImage(#imageLiteral(resourceName: "checkbox_tick"), for: .highlighted)
        makeAsHistoryButton.tintColor = App.Color.coolGrey
        makeAsHistoryButton.titleEdgeInsets = .init(top: 0, left: 4, bottom: 0, right: 0)
        makeAsHistoryButton.titleLabel?.font = App.Font.caption
        makeAsHistoryButton.titleLabel?.textColor = App.Color.steel
        makeAsHistoryButton.contentHorizontalAlignment = .left
        makeAsHistoryButton.addTarget(self, action: #selector(handleMakeAsHistoryButton), for: .touchUpInside)
        contentView.addSubview(makeAsHistoryButton)
        makeAsHistoryButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.tagsField.snp.bottom).offset(App.Layout.itemSpacingSmall)
            make.left.equalTo(self.contentView).inset(App.Layout.sideOffset)
            make.right.equalTo(self.contentView).inset(App.Layout.sideOffset)
            make.height.equalTo(40)
        }
    }

    private func setupSendButton() {
        sendButton.addTarget(self, action: #selector(handleSendButton), for: .touchUpInside)
        contentView.addSubview(sendButton)
        sendButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.makeAsHistoryButton.snp.bottom).offset(App.Layout.itemSpacingMedium)
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
