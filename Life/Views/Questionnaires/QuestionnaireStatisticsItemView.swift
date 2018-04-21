//
//  QuestionnaireStatisticsItemView.swift
//  Life
//
//  Created by Shyngys Kassymov on 05.04.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import SnapKit

class QuestionnaireStatisticsItemView: UIView {

    private(set) lazy var titleLabel = UILabel()

    private(set) lazy var votesImageView = UIImageView()
    private(set) lazy var votesLabel = UILabel()

    private var lastVariantView: UIView?

    var questionnaireQuestionStatistics: QuestionnaireQuestionStatistics

    init(questionnaireQuestionStatistics: QuestionnaireQuestionStatistics) {
        self.questionnaireQuestionStatistics = questionnaireQuestionStatistics

        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        titleLabel.preferredMaxLayoutWidth = titleLabel.frame.size.width
    }

    // MARK: - UI

    private func setupUI() {
        setupTitleLabel()
        setupQestionVariants()
        setupVoteViews()
    }

    private func setupTitleLabel() {
        titleLabel.font = App.Font.subheadAlts
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .black
        titleLabel.text = questionnaireQuestionStatistics.questionText
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.equalTo(self)
            make.right.equalTo(self)
        }
    }

    private func setupQestionVariants() {
        var variants = questionnaireQuestionStatistics.variants
        if let commentVariant = questionnaireQuestionStatistics.commentVariant {
            variants.append(commentVariant)
        }

        for idx in 0..<variants.count {
            let variant = variants[idx]

            let variantView = QuestionStatisticsView(questionStatistics: variant)
            addSubview(variantView)

            if idx == 0 {
                variantView.snp.makeConstraints { (make) in
                    make.top.equalTo(self.titleLabel.snp.bottom).offset(App.Layout.itemSpacingMedium)
                    make.left.equalTo(self)
                    make.right.equalTo(self)
                    make.height.equalTo(30)
                }
            } else {
                variantView.snp.makeConstraints { (make) in
                    make.top.equalTo(self.lastVariantView!.snp.bottom).offset(App.Layout.itemSpacingSmall)
                    make.left.equalTo(self)
                    make.right.equalTo(self)
                    make.height.equalTo(30)
                }
            }

            lastVariantView = variantView
        }
    }

    private func setupVoteViews() {
        votesImageView.contentMode = .scaleAspectFit
        votesImageView.image = #imageLiteral(resourceName: "poll")
        addSubview(votesImageView)
        votesImageView.snp.makeConstraints { (make) in
            make.top.equalTo(self.lastVariantView!.snp.bottom).offset(App.Layout.itemSpacingMedium)
            make.left.equalTo(self)
            make.bottom.equalTo(self)
            make.size.equalTo(CGSize(width: 24, height: 24))
        }

        votesLabel.font = App.Font.caption
        votesLabel.textColor = App.Color.steel

        let text = "\(questionnaireQuestionStatistics.totalVotes) голосов"
        let attText = NSMutableAttributedString(string: text)
        let allRange = NSRange(location: 0, length: text.count)
        let countRange = NSRange(location: 0, length: "\(questionnaireQuestionStatistics.totalVotes)".count)
        attText.addAttribute(.font, value: App.Font.caption, range: allRange)
        attText.addAttribute(.foregroundColor, value: App.Color.steel, range: allRange)
        attText.addAttribute(.font, value: App.Font.captionAlts, range: countRange)

        votesLabel.attributedText = attText

        addSubview(votesLabel)
        votesLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.votesImageView.snp.right).offset(App.Layout.itemSpacingSmall)
            make.centerY.equalTo(self.votesImageView)
        }
    }

}
