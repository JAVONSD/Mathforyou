//
//  QuestionnaireViewController.swift
//  Life
//
//  Created by Shyngys Kassymov on 04.04.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Lightbox
import Moya
import RxSwift
import RxCocoa
import SnapKit

class QuestionnaireViewController: UIViewController {

    private lazy var questionnaireView = QuestionnaireView()

    let questionnaireId: String

    private(set) var loadOnlyStatistics: Bool

    private var questionnaire: Questionnaire?
    private var questionnaireStatistics: QuestionnaireStatistics?

    private let provider = MoyaProvider<QuestionnairesService>(
        plugins: [
            AuthPlugin(tokenClosure: {
                return User.current.token
            })
        ]
    )

    let disposeBag = DisposeBag()

    init(questionnaireId: String, loadOnlyStatistics: Bool) {
        self.questionnaireId = questionnaireId
        self.loadOnlyStatistics = loadOnlyStatistics

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupBindings()

        if loadOnlyStatistics {
            loadQuestionnaireStatistics()
        } else {
            loadQuestionnaireDetails()
        }
    }

    // MARK: - Methods

    private func loadQuestionnaireDetails() {
        questionnaireView.set(isLoading: true)

        provider
            .rx
            .request(.questionnaire(id: questionnaireId))
            .filterSuccessfulStatusCodes()
            .subscribe { [weak self] response in
                guard let `self` = self else { return }

                self.questionnaireView.set(isLoading: false)

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

    private func loadQuestionnaireStatistics() {
        questionnaireView.set(isLoading: true)

        provider
            .rx
            .request(.questionnaireStatistics(id: questionnaireId))
            .filterSuccessfulStatusCodes()
            .subscribe { [weak self] response in
                guard let `self` = self else { return }

                self.questionnaireView.set(isLoading: false)

                switch response {
                case .success(let json):
                    if let questionnaireStatistics = try? JSONDecoder()
                        .decode(QuestionnaireStatistics.self, from: json.data) {
                        self.questionnaireStatistics = questionnaireStatistics
                        self.updateUI()
                    }
                case .error(let error):
                    print("Failed to get questionnaire statistics with error - \(error.localizedDescription)")
                }
            }
            .disposed(by: disposeBag)
    }

    private func open(image: URL, allImages: [URL]) {
        guard !allImages.isEmpty else { return }

        let images = allImages.map { LightboxImage(imageURL: $0) }
        let startIndex = allImages.index(of: image) ?? 0

        let controller = LightboxController(images: images, startIndex: startIndex)
        controller.dynamicBackground = true

        present(controller, animated: true, completion: nil)
    }

    private func addAnswer(
        questionnaireId: String,
        questionId: String,
        variantIds: [String],
        selectedComment: Bool,
        userComment: String) {
        questionnaireView.pollView.set(isLoading: true)

        provider
            .rx
            .request(.addAnswer(
                id: questionnaireId,
                questionId: questionId,
                variantIds: variantIds,
                isCommented: selectedComment,
                commentText: userComment
                ))
            .filterSuccessfulStatusCodes()
            .subscribe { [weak self] response in
                guard let `self` = self else { return }

                self.questionnaireView.pollView.set(isLoading: false)

                switch response {
                case .success:
                    self.questionnaireView.pollView.showNextQuestion()
                case .error(let error):
                    print("Failed to add answer to questionnaire with error - \(error.localizedDescription)")
                }
            }
            .disposed(by: disposeBag)
    }

    // MARK: - UI

    private func setupUI() {
        view.backgroundColor = .white

        view.addSubview(questionnaireView)
        questionnaireView.snp.makeConstraints { (make) in
            make.top.equalTo(self.topLayoutGuide.snp.bottom)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }
    }

    private func updateUI() {
        if loadOnlyStatistics, let statistics = questionnaireStatistics {
            questionnaireView.setStatisticsViewVisible(with: statistics)
        } else if let questionnaire = questionnaire {
            questionnaireView.setPollViewVisible(with: questionnaire)
        }

        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    private func setupBindings() {
        questionnaireView.headerView.closeButton.rx.tap
            .asDriver()
            .throttle(0.5)
            .drive(onNext: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)

        questionnaireView.statisticsView.headerView.closeButton?.rx.tap
            .asDriver()
            .throttle(0.5)
            .drive(onNext: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)

        questionnaireView.headerView.didTapImage = { [weak self] (urlStr, urlStrs) in
            let urls = urlStrs.compactMap { URL(string: $0) }
            if let url = URL(string: urlStr) {
                self?.open(image: url, allImages: urls)
            }
        }

        questionnaireView.pollView.didTapNext
            = { [weak self] (questionnaireId, questionId, variantsIds, selectedComment, userComment) in
            self?.addAnswer(
                questionnaireId: questionnaireId,
                questionId: questionId,
                variantIds: variantsIds,
                selectedComment: selectedComment,
                userComment: userComment
            )
        }
        questionnaireView.pollView.didFinish = { [weak self] in
            self?.loadOnlyStatistics = true
            self?.loadQuestionnaireStatistics()
        }
    }

}
