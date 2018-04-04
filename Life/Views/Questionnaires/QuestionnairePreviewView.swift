//
//  QuestionnairePreviewView.swift
//  Life
//
//  Created by Shyngys Kassymov on 04.04.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material
import NVActivityIndicatorView
import SnapKit

class QuestionnairePreviewView: UIView {

    private(set) lazy var headerView = NotificationHeaderView(image: nil, title: "", subtitle: nil)
    private(set) lazy var descriptionLabel = UILabel()

    private(set) lazy var authorTitleLabel = UILabel()
    private(set) lazy var authorLabel = UILabel()

    private(set) lazy var questionCountTitleLabel = UILabel()
    private(set) lazy var questionCountLabel = UILabel()

    private(set) lazy var answerCountTitleLabel = UILabel()
    private(set) lazy var answerCountLabel = UILabel()

    private(set) lazy var typeTitleLabel = UILabel()
    private(set) lazy var typeLabel = UILabel()

    private(set) lazy var viewStatistcisButton = Button(
        title: NSLocalizedString("see_statistics", comment: "").uppercased()
    )
    private(set) lazy var passButton = Button(
        title: NSLocalizedString("pass", comment: "").uppercased()
    )

    private(set) lazy var spinner = NVActivityIndicatorView(
        frame: .init(x: 0, y: 0, width: 44, height: 44),
        type: .circleStrokeSpin,
        color: App.Color.azure,
        padding: 0)

    private var viewStatisticsButtonTopConstraint: Constraint?
    private var viewStatisticsButtonHeightConstraint: Constraint?
    private var passButtonTopConstraint: Constraint?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        descriptionLabel.preferredMaxLayoutWidth = descriptionLabel.frame.size.width
        authorLabel.preferredMaxLayoutWidth = authorLabel.frame.size.width
    }

    // MARK: - Methods

    public func set(isLoading: Bool) {
        for view in subviews {
            view.isHidden = isLoading
        }

        spinner.isHidden = !isLoading
        isLoading ? spinner.startAnimating() : spinner.stopAnimating()
    }

    private func setup(titleLabel: UILabel) {
        titleLabel.font = App.Font.caption
        titleLabel.textColor = App.Color.steel
    }

    private func setup(label: UILabel) {
        label.font = App.Font.body
        label.textColor = .black
    }

    // MARK: - Methods

    public func showViewStatisticsButton() {
        viewStatistcisButton.isHidden = false
        viewStatistcisButton.alpha = 1

        viewStatisticsButtonTopConstraint?.update(offset: App.Layout.sideOffset)
        viewStatisticsButtonHeightConstraint?.update(offset: App.Layout.buttonHeight)
        passButtonTopConstraint?.update(offset: App.Layout.itemSpacingMedium)
    }

    // MARK: - UI

    private func setupUI() {
        backgroundColor = .white

        setupHeaderView()
        setupDescriptionLabel()
        setupAuthorLabels()
        setupQuestionCountLabels()
        setupAnswerCountLabels()
        setupTypeLabels()
        setupViewStatistcisButton()
        setupPassButton()
        setupSpinner()
    }

    private func setupHeaderView() {
        let insets = UIEdgeInsets.init(
            top: App.Layout.itemSpacingMedium,
            left: 0,
            bottom: App.Layout.itemSpacingMedium,
            right: 0)
        headerView.textStackView?.insets = insets

        addSubview(headerView)
        headerView.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.equalTo(self)
            make.right.equalTo(self)
        }
    }

    private func setupDescriptionLabel() {
        descriptionLabel.font = App.Font.body
        descriptionLabel.lineBreakMode = .byWordWrapping
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = .black
        addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.headerView.snp.bottom).offset(App.Layout.itemSpacingMedium)
            make.left.equalTo(self).inset(App.Layout.sideOffset)
            make.right.equalTo(self).inset(App.Layout.sideOffset)
        }
    }

    private func setupAuthorLabels() {
        setup(titleLabel: authorTitleLabel)
        authorTitleLabel.text = NSLocalizedString("author", comment: "")
        addSubview(authorTitleLabel)
        authorTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.descriptionLabel.snp.bottom).offset(App.Layout.itemSpacingMedium)
            make.left.equalTo(self).inset(App.Layout.sideOffset)
        }

        setup(label: authorLabel)
        authorLabel.lineBreakMode = .byWordWrapping
        authorLabel.numberOfLines = 0
        addSubview(authorLabel)
        authorLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.authorTitleLabel.snp.bottom).offset(App.Layout.itemSpacingSmall)
            make.left.equalTo(self).inset(App.Layout.sideOffset)
        }
    }

    private func setupQuestionCountLabels() {
        setup(titleLabel: questionCountTitleLabel)
        questionCountTitleLabel.text = NSLocalizedString("question_count", comment: "")
        addSubview(questionCountTitleLabel)
        questionCountTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.descriptionLabel.snp.bottom).offset(App.Layout.itemSpacingMedium)
            make.left.equalTo(self.authorTitleLabel.snp.right).offset(App.Layout.itemSpacingSmall)
            make.right.equalTo(self).inset(App.Layout.sideOffset)
            make.width.equalTo(self.authorTitleLabel)
        }

        setup(label: questionCountLabel)
        addSubview(questionCountLabel)
        questionCountLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.questionCountTitleLabel.snp.bottom).offset(App.Layout.itemSpacingSmall)
            make.left.equalTo(self.authorLabel.snp.right).offset(App.Layout.itemSpacingSmall)
            make.right.equalTo(self).inset(App.Layout.sideOffset)
            make.width.equalTo(self.authorLabel)
        }
    }

    private func setupAnswerCountLabels() {
        setup(titleLabel: answerCountTitleLabel)
        answerCountTitleLabel.text = NSLocalizedString("answered_employee_count", comment: "")
        addSubview(answerCountTitleLabel)
        answerCountTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.authorLabel.snp.bottom).offset(App.Layout.itemSpacingMedium)
            make.left.equalTo(self).inset(App.Layout.sideOffset)
        }

        setup(label: answerCountLabel)
        addSubview(answerCountLabel)
        answerCountLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.answerCountTitleLabel.snp.bottom).offset(App.Layout.itemSpacingSmall)
            make.left.equalTo(self).inset(App.Layout.sideOffset)
        }
    }

    private func setupTypeLabels() {
        setup(titleLabel: typeTitleLabel)
        typeTitleLabel.text = NSLocalizedString("questionnaire_type", comment: "")
        addSubview(typeTitleLabel)
        typeTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.authorLabel.snp.bottom).offset(App.Layout.itemSpacingMedium)
            make.left.equalTo(self.answerCountTitleLabel.snp.right).offset(App.Layout.itemSpacingSmall)
            make.right.equalTo(self).inset(App.Layout.sideOffset)
            make.width.equalTo(self.answerCountTitleLabel)
        }

        setup(label: typeLabel)
        addSubview(typeLabel)
        typeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.typeTitleLabel.snp.bottom).offset(App.Layout.itemSpacingSmall)
            make.left.equalTo(self.answerCountLabel.snp.right).offset(App.Layout.itemSpacingSmall)
            make.right.equalTo(self).inset(App.Layout.sideOffset)
            make.width.equalTo(self.answerCountLabel)
        }
    }

    private func setupViewStatistcisButton() {
        viewStatistcisButton.applyLightTheme()
        viewStatistcisButton.isHidden = true
        viewStatistcisButton.alpha = 0
        addSubview(viewStatistcisButton)
        viewStatistcisButton.snp.remakeConstraints { (make) in
            self.viewStatisticsButtonTopConstraint = make.top.equalTo(self.answerCountLabel.snp.bottom)
                .offset(0).constraint
            make.left.equalTo(self).inset(App.Layout.sideOffset)
            make.right.equalTo(self).inset(App.Layout.sideOffset)
            self.viewStatisticsButtonHeightConstraint = make.height.equalTo(0).constraint
        }
    }

    private func setupPassButton() {
        addSubview(passButton)
        passButton.snp.makeConstraints { (make) in
            self.passButtonTopConstraint = make.top.equalTo(self.viewStatistcisButton.snp.bottom)
                .offset(App.Layout.sideOffset).constraint
            make.left.equalTo(self).inset(App.Layout.sideOffset)
            make.bottom.equalTo(self).inset(App.Layout.sideOffset)
            make.right.equalTo(self).inset(App.Layout.sideOffset)
        }
    }

    private func setupSpinner() {
        addSubview(spinner)
        spinner.snp.makeConstraints { (make) in
            make.center.equalTo(self)
        }
    }

}
