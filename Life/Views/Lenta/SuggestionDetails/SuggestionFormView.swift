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
import TTGTagCollectionView

class SuggestionFormView: UIView, UITextFieldDelegate {

    private(set) lazy var headerView = NotificationHeaderView(
        image: nil,
        title: NSLocalizedString("new_suggestion", comment: ""),
        subtitle: nil
    )
    private(set) lazy var scrollView = UIScrollView()
    private(set) lazy var contentView = UIView()
    private(set) lazy var coverImageView = UIImageView()
    private(set) lazy var coverImageButton = FlatButton(
        title: NSLocalizedString("add_cover", comment: ""),
        titleColor: App.Color.steel
    )
    private(set) lazy var attachmentsView = AttachmentsView()
    private(set) lazy var attachmentButton = FlatButton()
    private(set) lazy var topicField = TextField(frame: .zero)
    private(set) lazy var textField = TextView(frame: .zero)
    private(set) lazy var tagsField = TextField(frame: .zero)
    private(set) lazy var tagsCollectionView = TTGTextTagCollectionView(frame: .zero)
    private(set) lazy var addAttachmentButton = FlatButton(
        title: NSLocalizedString("attach", comment: ""),
        titleColor: UIColor.black
    )
    private(set) lazy var sendButton = Button(
        title: NSLocalizedString("send", comment: "").uppercased()
    )

    private var coverImageHeightConstraint: Constraint?
    private var coverImageButtonTopConstraint: Constraint?
    private var attachmentButtonTopConstraint: Constraint?
    private var attachmentsViewTopConstraint: Constraint?

    var didTapCloseButton: (() -> Void)?
    var didTapCoverImageButton: (() -> Void)?
    var didTapAttachmentButton: (() -> Void)?
    var didTapSendButton: (() -> Void)?
    var didDeleteTag: ((String) -> Void)?
    var didTapAddTag: (() -> Void)?

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
    private func handleSendButton() {
        if let didTapSendButton = didTapSendButton {
            didTapSendButton()
        }
    }

    @objc
    private func handleAddTagButton() {
        if let didTapAddTag = didTapAddTag {
            didTapAddTag()
        }
    }

    // MARK: - Methods

    public func set(coverImage: UIImage) {
        coverImageView.image = coverImage

        let imageSize = coverImage.size
        let width = coverImageView.frame.size.width
        let height = width * imageSize.height / imageSize.width
        coverImageHeightConstraint?.update(offset: height)

        let offset = attachmentsView.isHidden
            ? App.Layout.itemSpacingMedium
            : 2 * App.Layout.itemSpacingMedium + AttachmentCollectionViewCell.height()

        coverImageButtonTopConstraint?.update(offset: offset)
        attachmentButtonTopConstraint?.update(offset: offset)
        attachmentsViewTopConstraint?.update(offset: App.Layout.itemSpacingMedium)

        coverImageButton.setTitle(NSLocalizedString("change_cover", comment: ""), for: .normal)
    }

    public func addAttachments(with urls: [URL], isImage: Bool) {
        if attachmentsView.isHidden {
            attachmentsView.isHidden = false

            let offset = coverImageView.image == nil
                ? App.Layout.itemSpacingMedium + AttachmentCollectionViewCell.height()
                : 2 * App.Layout.itemSpacingMedium + AttachmentCollectionViewCell.height()

            coverImageButtonTopConstraint?.update(offset: offset)
            attachmentButtonTopConstraint?.update(offset: offset)
        }

        var attachments = [Attachment]()

        for url in urls {
            let type: Attachment.AttachmentType = isImage ? .image : .file
            let attachment = Attachment(url: url, type: type)
            attachments.append(attachment)
        }

        attachmentsView.add(attachments: attachments)
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

        setupCoverImageView()
        setupCoverImageButton()
        setupAttachmentsView()
        setupAttachmentButton()
        setupTopicField()
        setupTextField()
        setupTagsField()
        setupTagsCollectionView()
        setupSendButton()
    }

    private func setupCoverImageView() {
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.layer.cornerRadius = App.Layout.cornerRadiusSmall
        coverImageView.layer.masksToBounds = true
        contentView.addSubview(coverImageView)
        coverImageView.snp.makeConstraints { (make) in
            make.top.equalTo(self.contentView).inset(App.Layout.sideOffset)
            make.left.equalTo(self.contentView).inset(App.Layout.sideOffset)
            make.right.equalTo(self.contentView).inset(App.Layout.sideOffset)
            self.coverImageHeightConstraint = make.height.equalTo(0).constraint
        }
    }

    private func setupCoverImageButton() {
        coverImageButton.image = #imageLiteral(resourceName: "ic-insert-photo")
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
            self.coverImageButtonTopConstraint = make.top.equalTo(self.coverImageView.snp.bottom)
                .offset(0).constraint
            make.left.equalTo(self.contentView).inset(App.Layout.sideOffset)
            make.height.equalTo(72)
        }
    }

    private func setupAttachmentsView() {
        attachmentsView.isHidden = true
        contentView.addSubview(attachmentsView)
        attachmentsView.snp.makeConstraints { (make) in
            self.attachmentsViewTopConstraint = make.top.equalTo(self.coverImageView.snp.bottom)
                .offset(0).constraint
            make.left.equalTo(self.contentView)
            make.right.equalTo(self.contentView)
        }
    }

    private func setupAttachmentButton() {
        attachmentButton.image = #imageLiteral(resourceName: "attach-file")
        attachmentButton.tintColor = App.Color.coolGrey
        attachmentButton.addTarget(self, action: #selector(handleAttachmentButton), for: .touchUpInside)
        attachmentButton.layer.cornerRadius = App.Layout.cornerRadius
        attachmentButton.layer.masksToBounds = true
        attachmentButton.layer.borderColor = App.Color.coolGrey.cgColor
        attachmentButton.layer.borderWidth = 0.5
        contentView.addSubview(attachmentButton)
        attachmentButton.snp.makeConstraints { (make) in
            self.attachmentButtonTopConstraint = make.top.equalTo(self.coverImageView.snp.bottom)
                .offset(0).constraint
            make.left.equalTo(self.coverImageButton.snp.right).offset(App.Layout.itemSpacingSmall)
            make.right.equalTo(self.contentView).inset(App.Layout.sideOffset)
            make.height.equalTo(72)
            make.width.equalTo(72)
        }
    }

    private func setupTopicField() {
        topicField.delegate = self
        topicField.placeholder = NSLocalizedString("title", comment: "")
        contentView.addSubview(topicField)
        topicField.snp.makeConstraints { (make) in
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

    private func setupTagsField() {
        tagsField.addRightButtonOnKeyboardWithText(
            NSLocalizedString("create_tag", comment: ""),
            target: self,
            action: #selector(handleAddTagButton)
        )
        tagsField.keyboardToolbar.tintColor = .black
        tagsField.placeholder = NSLocalizedString("tags", comment: "")
        contentView.addSubview(tagsField)
        tagsField.snp.makeConstraints { (make) in
            make.top.equalTo(self.textField.snp.bottom).offset(App.Layout.sideOffset)
            make.left.equalTo(self.contentView).inset(App.Layout.sideOffset)
            make.right.equalTo(self.contentView).inset(App.Layout.sideOffset)
        }
    }

    private func setupTagsCollectionView() {
        tagsCollectionView.delegate = self
        tagsCollectionView.showsVerticalScrollIndicator = false
        tagsCollectionView.horizontalSpacing = 6.0
        tagsCollectionView.verticalSpacing = 8.0
        contentView.addSubview(tagsCollectionView)

        let config = tagsCollectionView.defaultConfig
        config?.tagTextFont = App.Font.body
        config?.tagTextColor = .white
        config?.tagSelectedTextColor = .white
        config?.tagBackgroundColor = App.Color.azure
        config?.tagSelectedBackgroundColor = App.Color.azure
        config?.tagBorderColor = .clear
        config?.tagSelectedBorderColor = .clear
        config?.tagBorderWidth = 0
        config?.tagSelectedBorderWidth = 0
        config?.tagShadowColor = .clear
        config?.tagShadowOffset = .zero
        config?.tagShadowOpacity = 0
        config?.tagShadowRadius = 0
        config?.tagCornerRadius = App.Layout.cornerRadiusSmall / 2

        tagsCollectionView.snp.makeConstraints { (make) in
            make.top
                .equalTo(self.tagsField.snp.bottom)
                .offset(App.Layout.itemSpacingSmall)
            make.left.equalTo(self.contentView).inset(App.Layout.sideOffset)
            make.right.equalTo(self.contentView).inset(App.Layout.sideOffset)
        }
    }

    private func setupSendButton() {
        sendButton.addTarget(self, action: #selector(handleSendButton), for: .touchUpInside)
        contentView.addSubview(sendButton)
        sendButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.tagsCollectionView.snp.bottom).offset(App.Layout.itemSpacingMedium)
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

extension SuggestionFormView: TTGTextTagCollectionViewDelegate {
    //swiftlint:disable line_length
    func textTagCollectionView(_ textTagCollectionView: TTGTextTagCollectionView!, didTapTag tagText: String!, at index: UInt, selected: Bool) {
        textTagCollectionView.removeTag(at: index)

        if let didDeleteTag = didDeleteTag {
            didDeleteTag(tagText)
        }
    }
    //swiftlint:enable line_length
}
