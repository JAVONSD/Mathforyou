//
//  QuestionFormView.swift
//  Life
//
//  Created by Shyngys Kassymov on 23.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material
import SnapKit

class QuestionFormView: UIView, UITextFieldDelegate {

    private(set) lazy var headerView = NotificationHeaderView(
        image: nil,
        title: NSLocalizedString("add_question", comment: ""),
        subtitle: nil
    )
    private(set) lazy var scrollView = UIScrollView()
    private(set) lazy var contentView = UIView()
    private(set) lazy var titleField = TextField(frame: .zero)
    private(set) lazy var textField = TextView(frame: .zero)
    private(set) lazy var addButton = Button(
        title: NSLocalizedString("ask_question", comment: "").uppercased()
    )

    var didTapCloseButton: (() -> Void)?
    var didTapAddButton: (() -> Void)?

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
    private func handleAddButton() {
        if let didTapAddButton = didTapAddButton {
            didTapAddButton()
        }
    }

    // MARK: - UI

    private func setupUI() {
        setupHeaderView()
        setupScrollView()
    }

    private func setupHeaderView() {
        headerView.backgroundColor = .white
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

        setupTitleField()
        setupTextView()
        setupAddButton()
    }

    private func setupTitleField() {
        titleField.delegate = self
        titleField.placeholder = NSLocalizedString("topic", comment: "")
        contentView.addSubview(titleField)
        titleField.snp.makeConstraints { (make) in
            make.top
                .equalTo(self.contentView)
                .inset(App.Layout.sideOffset)
            make.left.equalTo(self.contentView).inset(App.Layout.sideOffset)
            make.right.equalTo(self.contentView).inset(App.Layout.sideOffset)
        }
    }

    private func setupTextView() {
        textField.backgroundColor = App.Color.paleGrey
        textField.layer.borderColor = App.Color.coolGrey.cgColor
        textField.layer.borderWidth = 0.5
        textField.layer.cornerRadius = App.Layout.cornerRadius
        textField.layer.masksToBounds = true
        textField.placeholder = NSLocalizedString("question_text", comment: "")
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
            make.height.equalTo(144)
        }
    }

    private func setupAddButton() {
        addButton.addTarget(self, action: #selector(handleAddButton), for: .touchUpInside)
        contentView.addSubview(addButton)
        addButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.textField.snp.bottom).offset(App.Layout.sideOffset)
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
