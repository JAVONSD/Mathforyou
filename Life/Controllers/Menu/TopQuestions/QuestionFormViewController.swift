//
//  QuestionFormViewController.swift
//  Life
//
//  Created by Shyngys Kassymov on 23.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class QuestionFormViewController: UIViewController, Stepper {

    private(set) lazy var questionFormView = QuestionFormView(frame: .zero)

    private let viewModel = QuestionFormViewModel()
    private let disposeBag = DisposeBag()

    var didAddQuestion: ((Question) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        loadTags()
    }

    // MARK: - Methods

    private func loadTags() {
        viewModel.getTags()
        viewModel.tagsSubject.subscribe(onNext: { [weak self] tags in
            guard let `self` = self else { return }
            self.questionFormView.tagsField.setAsPicker(with: tags.map { $0.name }, setText: false)
            self.questionFormView.tagsField.addOrUpdateToggleToolbar()
        })
        .disposed(by: disposeBag)
    }

    // MARK: - UI

    private func setupUI() {
        view.backgroundColor = .white

        setupQuestionFormView()
    }

    private func setupQuestionFormView() {
        view.addSubview(questionFormView)
        questionFormView.snp.makeConstraints { (make) in
            make.top.equalTo(self.topLayoutGuide.snp.bottom)
            make.left.equalTo(self.view)
            make.bottom.equalTo(self.view)
            make.right.equalTo(self.view)
        }

        bindCloseButton()
        bindTextView()
        bindTags()
        bindIsAnonymousButton()
        bindAddButton()
    }

    private func bindCloseButton() {
        questionFormView.headerView.closeButton?
            .rx
            .tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.step.accept(AppStep.createQuestionDone)
            })
            .disposed(by: disposeBag)
    }

    private func bindTextView() {
        questionFormView.textField
            .rx
            .text
            .orEmpty
            .bind(to: viewModel.questionText)
            .disposed(by: disposeBag)
    }

    private func bindIsAnonymousButton() {
        questionFormView.isAnonymousButton
            .rx
            .tap
            .asDriver()
            .drive(onNext: { [weak self] in
                let isAnonymousButton = self?.questionFormView.isAnonymousButton
                let isAnonymous = isAnonymousButton?.isSelected ?? false
                isAnonymousButton?.isSelected = !isAnonymous
                isAnonymousButton?.tintColor = !isAnonymous ? App.Color.azure : App.Color.coolGrey
                self?.viewModel.isAnanymous.onNext(!isAnonymous)
            })
            .disposed(by: disposeBag)
    }

    private func bindTags() {
        questionFormView.tagsField.didTapAdd = { [weak self] text in
            self?.viewModel.userAddedTags.insert(text)
            self?.questionFormView.tagsCollectionView.addTag(text)
        }
        questionFormView.tagsField.didTapSelect = { [weak self] tagIdx in
            guard let `self` = self else { return }
            let tags = (try? self.viewModel.tagsSubject.value()) ?? []
            if tags.count > tagIdx {
                self.viewModel.userTags.insert(tags[tagIdx])
                self.questionFormView.tagsCollectionView.addTag(tags[tagIdx].name)
            }
        }
        questionFormView.didDeleteTag = { [weak self] tagText in
            guard let `self` = self else { return }
            self.viewModel.userTags = self.viewModel.userTags.filter({ tag -> Bool in
                return tag.name != tagText
            })
            self.viewModel.userAddedTags.remove(tagText)
        }
    }

    private func bindAddButton() {
        questionFormView.addButton
            .rx
            .tap
            .throttle(0.5, scheduler: MainScheduler.instance)
            .withLatestFrom(viewModel.isLoadingSubject)
            .filter { !$0 }
            .subscribe(onNext: { [weak self] _ in
                self?.view.endEditing(true)
                self?.viewModel.createQuestion()
            })
            .disposed(by: disposeBag)
        viewModel.isLoadingSubject.skip(1).subscribe(onNext: { [weak self] isLoading in
            self?.questionFormView.addButton.buttonState = isLoading ? .loading : .normal
        }).disposed(by: disposeBag)
        viewModel.questionCreatedSubject.subscribe(onNext: {[weak self] question in
            if let didAddQuestion = self?.didAddQuestion {
                didAddQuestion(question)
            }
            self?.step.accept(AppStep.createQuestionDone)
        }).disposed(by: disposeBag)
        viewModel.errorSubject.subscribe(onNext: {[weak self] error in
            let errorMessages = error.parseMessages()
            if let key = errorMessages.keys.first,
                let message = errorMessages[key] {
                self?.showToast(message)
            }
        }).disposed(by: disposeBag)
    }

}
