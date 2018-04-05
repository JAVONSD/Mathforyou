//
//  QuestionStatisticsView.swift
//  Life
//
//  Created by Shyngys Kassymov on 05.04.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Hue
import SnapKit

class QuestionStatisticsView: UIView {

    private(set) lazy var progressView = UIView()
    private(set) lazy var variantTextLabel = UILabel()
    private(set) lazy var variantPercentageLabel = UILabel()

    var questionStatistics: QuestionnaireVariantStatistics

    init(questionStatistics: QuestionnaireVariantStatistics) {
        self.questionStatistics = questionStatistics

        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        variantTextLabel.preferredMaxLayoutWidth = variantTextLabel.frame.size.width
    }

    // MARK: - UI

    private func setupUI() {
        backgroundColor = UIColor(hex: "#DCE2EB")

        layer.cornerRadius = App.Layout.cornerRadiusSmall
        layer.masksToBounds = true

        setupProgressView()
        setupQuestionTextLabel()
        setupQuestionPercentageLabel()
    }

    private func setupProgressView() {
        progressView.backgroundColor = UIColor(hex: "#B7CCEB")
        addSubview(progressView)
        progressView.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.equalTo(self)
            make.bottom.equalTo(self)
            make.width.equalTo(self).multipliedBy(CGFloat(questionStatistics.percentage) / 100)
        }
    }

    private func setupQuestionTextLabel() {
        variantTextLabel.font = App.Font.body
        variantTextLabel.lineBreakMode = .byWordWrapping
        variantTextLabel.numberOfLines = 0
        variantTextLabel.textColor = .black
        variantTextLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        variantTextLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        variantTextLabel.text = questionStatistics.variantText
        addSubview(variantTextLabel)
        variantTextLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self).inset(App.Layout.itemSpacingSmall)
            make.left.equalTo(self).inset(12)
            make.bottom.equalTo(self).inset(App.Layout.itemSpacingSmall)
        }
    }

    private func setupQuestionPercentageLabel() {
        variantPercentageLabel.font = App.Font.body
        variantPercentageLabel.textColor = .black
        variantPercentageLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        variantPercentageLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        variantPercentageLabel.text = "\(questionStatistics.percentage)%"
        addSubview(variantPercentageLabel)
        variantPercentageLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self).inset(App.Layout.itemSpacingSmall)
            make.left.equalTo(self.variantTextLabel.snp.right).offset(12)
            make.bottom.equalTo(self).inset(App.Layout.itemSpacingSmall)
            make.right.equalTo(self).inset(12)
        }
    }

}
