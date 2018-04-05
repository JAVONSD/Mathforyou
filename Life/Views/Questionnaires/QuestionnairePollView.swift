//
//  QuestionnairePollView.swift
//  Life
//
//  Created by Shyngys Kassymov on 04.04.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material
import SnapKit
import RxCocoa
import RxSwift

class QuestionnairePollView: UIView {

    private(set) lazy var titleLabel = UILabel()
    private(set) lazy var questionNumberLabel = UILabel()
    private(set) lazy var minAnswerCountLabel = UILabel()

    private(set) lazy var questionsContentView = UIView()
    private(set) lazy var textView = TextView()

    private(set) lazy var totalAnswersImageView = UIImageView()
    private(set) lazy var totalAnswersLabel = UILabel()

    private(set) lazy var prevButton = Button(title: NSLocalizedString("back", comment: "").uppercased())
    private(set) lazy var nextButton = Button(title: "")

    private var didSetup = false

    var questionnaire: Questionnaire!
    private(set) var currentQuestionIdx = 0

    private(set) var selectedVariantIds = Set<String>()
    private(set) var selectedComment = false
    private(set) var userComment = ""

    var didTapNext: ((String, String, [String], Bool, String) -> Void)?
    var didFinish: (() -> Void)?

    let disposeBag = DisposeBag()

    override func layoutSubviews() {
        super.layoutSubviews()

        titleLabel.preferredMaxLayoutWidth = titleLabel.frame.size.width
    }

    // MARK: - Mewthods

    public func build(with questionnaire: Questionnaire) {
        self.questionnaire = questionnaire

        if !didSetup {
            didSetup = true
            setupUI()
        }

        updateUI()
    }

    @objc
    public func showPrevQuestion() {
        guard currentQuestionIdx > 0 else { return }

        currentQuestionIdx -= 1
        updateUI()
    }

    @objc
    public func submitAndShowNextQuestion() {
        guard currentQuestionIdx < questionnaire.questions.count else {
            return
        }
        let question = questionnaire.questions[currentQuestionIdx]
        didTapNext?(questionnaire.id, question.id, Array(selectedVariantIds), selectedComment, userComment)
    }

    @objc
    public func showNextQuestion() {
        guard currentQuestionIdx < questionnaire.questions.count - 1 else {
            didFinish?()
            return
        }

        currentQuestionIdx += 1
        updateUI()
    }

    @objc
    private func handleVariant(_ button: UIButton) {
        let idx = button.tag
        guard currentQuestionIdx < questionnaire.questions.count,
            idx <= questionnaire.questions[currentQuestionIdx].variants.count else {
            return
        }

        let question = questionnaire.questions[currentQuestionIdx]

        let isSelected = !button.isSelected

        if question.maxAnswersQuantity == 1 {
            selectedVariantIds.removeAll()

            selectedComment = false
            textView.isUserInteractionEnabled = false
            textView.alpha = 0.5

            for subview in questionsContentView.subviews {
                if let button = subview as? FlatButton {
                    button.tintColor = App.Color.coolGrey
                    button.isSelected = false
                }
            }
        }

        if idx == question.variants.count {
            selectedComment = isSelected
            textView.isUserInteractionEnabled = isSelected
            textView.alpha = isSelected ? 1 : 0.5
        } else {
            let variant = question.variants[idx]
            if isSelected {
                if selectedVariantIds.count <= question.maxAnswersQuantity {
                    selectedVariantIds.insert(variant.id)
                }
            } else {
                selectedVariantIds.remove(variant.id)
            }
        }

        questionnaire.questions[currentQuestionIdx].userAnswer = Array(selectedVariantIds)
        questionnaire.questions[currentQuestionIdx].userComment = selectedComment ? userComment : ""

        button.tintColor = isSelected ? App.Color.midGreen : App.Color.coolGrey
        button.isSelected = isSelected
    }

    public func set(isLoading: Bool) {
        questionsContentView.isUserInteractionEnabled = !isLoading
        questionsContentView.alpha = isLoading ? 0.5 : 1

        prevButton.isUserInteractionEnabled = !isLoading
        prevButton.alpha = isLoading ? 0.5 : 1

        nextButton.buttonState = isLoading ? .loading : .normal
    }

    // MARK: - UI

    private func setupUI() {
        setupTitleLabel()
        setupQuestionNumberLabel()
        setupMinAnswerCountLabel()
        setupQuestionsContentView()
        setupTotalAnswersViews()
        setupButtons()
    }

    private func updateUI() {
        guard questionnaire.questions.count > currentQuestionIdx else { return }

        titleLabel.text = questionnaire.title
        questionNumberLabel.text = "\(currentQuestionIdx + 1)/\(questionnaire.questions.count) вопросов"

        buildQuestionView()

        let totalAnswers = questionnaire.questions[currentQuestionIdx].totalAnswers
        let text = "\(totalAnswers) голосов"
        let attText = NSMutableAttributedString(string: text)
        let allRange = NSMakeRange(0, text.count)
        let countRange = NSMakeRange(0, "\(totalAnswers)".count)
        attText.addAttribute(.font, value: App.Font.caption, range: allRange)
        attText.addAttribute(.foregroundColor, value: App.Color.steel, range: allRange)
        attText.addAttribute(.font, value: App.Font.captionAlts, range: countRange)
        totalAnswersLabel.attributedText = attText

        prevButton.isHidden = currentQuestionIdx == 0

        let title = currentQuestionIdx < questionnaire.questions.count - 1
            ? NSLocalizedString("next", comment: "")
            : NSLocalizedString("finish", comment: "")
        nextButton.title = title.uppercased()
    }

    private func buildQuestionView() {
        for subview in questionsContentView.subviews {
            subview.removeFromSuperview()
        }

        let question = questionnaire.questions[currentQuestionIdx]

        selectedVariantIds.removeAll()
        for answer in question.userAnswer {
            selectedVariantIds.insert(answer)
        }
        selectedComment = !question.userComment.isEmpty
        userComment = question.userComment

        minAnswerCountLabel.text = "Выберите \(question.minAnswersQuantity) варианта"

        let canComment = question.canComment

        var previousView: UIView?
        for idx in 0..<question.variants.count {
            let variant = question.variants[idx]
            let isSelected = selectedVariantIds.contains(variant.id)

            let button = variantButton(variant.text)
            button.tintColor = isSelected ? App.Color.midGreen : App.Color.coolGrey
            button.isSelected = isSelected
            button.tag = idx
            button.addTarget(self, action: #selector(handleVariant(_:)), for: .touchUpInside)
            questionsContentView.addSubview(button)

            if idx == 0 {
                button.snp.makeConstraints { (make) in
                    make.top.equalTo(self.questionsContentView)
                    make.left.equalTo(self.questionsContentView)
                    make.right.equalTo(self.questionsContentView)
                }
            } else if idx < question.variants.count - 1 {
                button.snp.makeConstraints { (make) in
                    make.top.equalTo(previousView!.snp.bottom).offset(App.Layout.itemSpacingSmall)
                    make.left.equalTo(self.questionsContentView)
                    make.right.equalTo(self.questionsContentView)
                }
            } else {
                button.snp.makeConstraints { (make) in
                    make.top.equalTo(previousView!.snp.bottom).offset(App.Layout.itemSpacingSmall)
                    make.left.equalTo(self.questionsContentView)
                    make.right.equalTo(self.questionsContentView)
                    if !canComment {
                        make.bottom.equalTo(self.questionsContentView)
                    }
                }
            }

            previousView = button
        }

        if canComment {
            let button = variantButton(NSLocalizedString("other_in_comment", comment: ""))
            button.tintColor = selectedComment ? App.Color.midGreen : App.Color.coolGrey
            button.isSelected = selectedComment
            button.tag = question.variants.count
            button.addTarget(self, action: #selector(handleVariant(_:)), for: .touchUpInside)
            questionsContentView.addSubview(button)
            button.snp.makeConstraints { (make) in
                make.top.equalTo(previousView!.snp.bottom).offset(App.Layout.itemSpacingSmall)
                make.left.equalTo(self.questionsContentView)
                make.right.equalTo(self.questionsContentView)
            }

            textView.backgroundColor = App.Color.paleGrey
            textView.layer.borderColor = App.Color.coolGrey.cgColor
            textView.layer.borderWidth = 0.5
            textView.layer.cornerRadius = App.Layout.cornerRadius
            textView.layer.masksToBounds = true
            textView.placeholder = NSLocalizedString("write_comment", comment: "")
            textView.textContainerInsets = EdgeInsets(
                top: 14,
                left: App.Layout.itemSpacingMedium,
                bottom: 14,
                right: App.Layout.itemSpacingMedium
            )
            textView.isUserInteractionEnabled = selectedComment
            textView.alpha = selectedComment ? 1 : 0.5
            textView.text = userComment
            textView.rx.text.orEmpty.subscribe(onNext: { [weak self] text in
                guard let `self` = self else { return }
                self.userComment = text
                self.questionnaire.questions[self.currentQuestionIdx]
                    .userComment = self.selectedComment ? text : ""
            }).disposed(by: disposeBag)
            questionsContentView.addSubview(textView)
            textView.snp.makeConstraints { (make) in
                make.top.equalTo(button.snp.bottom).offset(App.Layout.itemSpacingSmall)
                make.left.equalTo(self.questionsContentView)
                make.right.equalTo(self.questionsContentView)
                make.bottom.equalTo(self.questionsContentView)
                make.height.equalTo(56)
            }
        }
    }

    private func variantButton(_ title: String) -> FlatButton {
        let button = FlatButton(title: title)
        button.setImage(#imageLiteral(resourceName: "checkbox_empty"), for: .normal)
        button.setImage(#imageLiteral(resourceName: "checkbox_tick"), for: .selected)
        button.setImage(#imageLiteral(resourceName: "checkbox_tick"), for: .highlighted)
        button.titleEdgeInsets = .init(top: 0, left: 4, bottom: 0, right: 0)
        button.titleLabel?.font = App.Font.body
        button.titleLabel?.textColor = App.Color.steel
        button.contentHorizontalAlignment = .left
        return button
    }

    private func setupTitleLabel() {
        titleLabel.font = App.Font.subheadAlts
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .black
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self).inset(App.Layout.itemSpacingMedium)
            make.left.equalTo(self).inset(App.Layout.sideOffset)
            make.right.equalTo(self).inset(App.Layout.sideOffset)
        }
    }

    private func setupQuestionNumberLabel() {
        questionNumberLabel.font = App.Font.body
        questionNumberLabel.textColor = App.Color.steel
        addSubview(questionNumberLabel)
        questionNumberLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(App.Layout.itemSpacingMedium)
            make.right.equalTo(self).inset(App.Layout.sideOffset)
        }
    }

    private func setupMinAnswerCountLabel() {
        minAnswerCountLabel.font = App.Font.caption
        minAnswerCountLabel.textColor = App.Color.azure
        addSubview(minAnswerCountLabel)
        minAnswerCountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self).inset(App.Layout.sideOffset)
            make.right.equalTo(self.questionNumberLabel.snp.left).offset(-App.Layout.itemSpacingSmall)
            make.width.equalTo(self.questionNumberLabel)
            make.centerY.equalTo(self.questionNumberLabel)
        }
    }

    private func setupQuestionsContentView() {
        addSubview(questionsContentView)
        questionsContentView.snp.makeConstraints { (make) in
            make.top.equalTo(self.questionNumberLabel.snp.bottom).offset(App.Layout.itemSpacingSmall)
            make.left.equalTo(self).inset(App.Layout.sideOffset)
            make.right.equalTo(self).inset(App.Layout.sideOffset)
        }
    }

    private func setupTotalAnswersViews() {
        totalAnswersImageView.contentMode = .scaleAspectFit
        totalAnswersImageView.image = #imageLiteral(resourceName: "poll")
        addSubview(totalAnswersImageView)
        totalAnswersImageView.snp.makeConstraints { (make) in
            make.top.equalTo(self.questionsContentView.snp.bottom).offset(App.Layout.itemSpacingMedium)
            make.left.equalTo(self).inset(App.Layout.sideOffset)
            make.size.equalTo(CGSize(width: 24, height: 24))
        }

        totalAnswersLabel.font = App.Font.caption
        totalAnswersLabel.textColor = App.Color.steel
        addSubview(totalAnswersLabel)
        totalAnswersLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.totalAnswersImageView.snp.right).offset(App.Layout.itemSpacingSmall)
            make.centerY.equalTo(self.totalAnswersImageView)
        }
    }

    private func setupButtons() {
        prevButton.applyLightTheme()
        prevButton.isHidden = true
        prevButton.addTarget(self, action: #selector(showPrevQuestion), for: .touchUpInside)
        addSubview(prevButton)
        prevButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.totalAnswersImageView.snp.bottom).offset(App.Layout.itemSpacingMedium)
            make.left.equalTo(self).inset(App.Layout.sideOffset)
            make.bottom.equalTo(self).inset(App.Layout.sideOffset)
        }

        nextButton.addTarget(self, action: #selector(submitAndShowNextQuestion), for: .touchUpInside)
        addSubview(nextButton)
        nextButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.totalAnswersImageView.snp.bottom).offset(App.Layout.itemSpacingMedium)
            make.left.equalTo(self.prevButton.snp.right).offset(App.Layout.sideOffset)
            make.right.equalTo(self).inset(App.Layout.sideOffset)
            make.width.equalTo(self.prevButton)
        }
    }

}
