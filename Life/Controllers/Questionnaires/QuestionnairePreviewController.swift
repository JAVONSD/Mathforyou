//
//  QuestionnairePreviewController.swift
//  Life
//
//  Created by Shyngys Kassymov on 04.04.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Moya
import RxSwift
import RxCocoa
import SnapKit

class QuestionnairePreviewController: UIViewController {

    private lazy var previewView = QuestionnairePreviewView()

    var didTapPass: (() -> Void)?
    var didTapViewStatistics: (() -> Void)?

    let questionnaireId: String
    private var questionnaire: Questionnaire?

    private let provider = MoyaProvider<QuestionnairesService>(
        plugins: [
            AuthPlugin(tokenClosure: {
                return User.current.token
            })
        ]
    )

    let disposeBag = DisposeBag()

    init(questionnaireId: String) {
        self.questionnaireId = questionnaireId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupBindings()
        loadQuestionnaireDetails()
    }

    // MARK: - Methods

    private func loadQuestionnaireDetails() {
        previewView.set(isLoading: true)

        provider
            .rx
            .request(.questionnaireShortInfo(id: questionnaireId))
            .filterSuccessfulStatusCodes()
            .subscribe { [weak self] response in
                guard let `self` = self else { return }

                self.previewView.set(isLoading: false)

                switch response {
                case .success(let json):
                    if let questionnaire = try? JSONDecoder().decode(Questionnaire.self, from: json.data) {
                        self.questionnaire = questionnaire
                        self.updateUI()
                    }
                case .error(let error):
                    print("Failed to get questionnaire details with error - \(error.localizedDescription)")
                }
            }
            .disposed(by: disposeBag)
    }

    // MARK: - UI

    private func setupUI() {
        view.addSubview(previewView)
        previewView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }

        updateUI()
    }

    private func updateUI() {
        previewView.headerView.titleLabel?.text = questionnaire?.title
        previewView.descriptionLabel.text = questionnaire?.description
        previewView.authorLabel.text = questionnaire?.authorName
        previewView.questionCountLabel.text = "\(questionnaire?.questionsQuantity ?? 0)"
        previewView.answerCountLabel.text = "\(questionnaire?.interviewedUsersQuantity ?? 0)"

        previewView.typeLabel.text = (questionnaire?.isAnonymous ?? false)
            ? NSLocalizedString("anonymous", comment: "")
            : NSLocalizedString("not_anonymous", comment: "")

        let title = (questionnaire?.isCurrentUserInterviewed ?? false)
            ? NSLocalizedString("change_answers", comment: "")
            : NSLocalizedString("pass", comment: "")
        previewView.passButton.title = title.uppercased()

        if (questionnaire?.isCurrentUserInterviewed ?? false) {
            previewView.showViewStatisticsButton()
        }

        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    private func setupBindings() {
        previewView.headerView.closeButton?.rx.tap
            .asDriver()
            .throttle(0.5)
            .drive(onNext: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)

        previewView.viewStatistcisButton.rx.tap
            .asDriver()
            .throttle(0.5)
            .drive(onNext: { [weak self] in
                self?.dismiss(animated: true, completion: { [weak self] in
                    self?.didTapViewStatistics?()
                })
            })
            .disposed(by: disposeBag)

        previewView.passButton.rx.tap
            .asDriver()
            .throttle(0.5)
            .drive(onNext: { [weak self] in
                self?.dismiss(animated: true, completion: { [weak self] in
                    self?.didTapPass?()
                })
            })
            .disposed(by: disposeBag)
    }

}
