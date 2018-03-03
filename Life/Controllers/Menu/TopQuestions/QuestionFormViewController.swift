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
import UITextField_AutoSuggestion

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
        viewModel.isLoadingTagsSubject.subscribe(onNext: { [weak self] isLoadingTags in
            guard let `self` = self else { return }
            if self.questionFormView.tagsField.isFirstResponder {
                self.questionFormView.tagsField.setLoading(isLoadingTags)
            }
        }).disposed(by: disposeBag)
        viewModel.getTags()
        viewModel.tagsSubject.subscribe(onNext: { [weak self] tags in
            guard let `self` = self else { return }
//            self.questionFormView.tagsField.setAsPicker(with: tags.map { $0.name }, setText: false)
//            self.questionFormView.tagsField.addOrUpdateToggleToolbar()
            if let tableView = self.questionFormView.tagsField.tableView {
                tableView.reloadData()
            }
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
        questionFormView.didDeleteTag = { [weak self] tagText in
            guard let `self` = self else { return }
            self.viewModel.userTags = self.viewModel.userTags.filter({ tag -> Bool in
                return tag.name != tagText
            })
            self.viewModel.userAddedTags.remove(tagText)
        }
        questionFormView.didTapAddTag = { [weak self] in
            if let text = self?.questionFormView.tagsField.text,
                !text.isEmpty {
                self?.viewModel.userAddedTags.insert(text)
                self?.questionFormView.tagsCollectionView.addTag(text)
                self?.questionFormView.tagsField.text = nil
                self?.questionFormView.tagsField.insertText("")
            }
        }

        questionFormView.tagsField.autoSuggestionDataSource = self
        questionFormView.tagsField.observeChanges()
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

//swiftlint:disable line_length
extension QuestionFormViewController: UITextFieldAutoSuggestionDataSource {
    func autoSuggestionField(_ field: UITextField!, tableView: UITableView!, cellForRowAt indexPath: IndexPath!, forText text: String!) -> UITableViewCell! {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: App.CellIdentifier.suggestionCellId)

        let cell = tableView.dequeueReusableCell(withIdentifier: App.CellIdentifier.suggestionCellId, for: indexPath)
        if let tags = try? viewModel.filteredTagsSubject.value(), tags.count > indexPath.row {
            cell.textLabel?.text = tags[indexPath.row].name
        }
        return cell
    }

    func autoSuggestionField(_ field: UITextField!, tableView: UITableView!, numberOfRowsInSection section: Int, forText text: String!) -> Int {
        if let tags = try? viewModel.filteredTagsSubject.value() {
            return tags.count
        }
        return 0
    }

    func autoSuggestionField(_ field: UITextField!, tableView: UITableView!, didSelectRowAt indexPath: IndexPath!, forText text: String!) {
        let tags = (try? self.viewModel.filteredTagsSubject.value()) ?? []
        if tags.count > indexPath.row {
            viewModel.userTags.insert(tags[indexPath.row])
            questionFormView.tagsCollectionView.addTag(tags[indexPath.row].name)
            questionFormView.tagsField.text = nil
        }
    }

    func autoSuggestionField(_ field: UITextField!, textChanged text: String!) {
        if let tags = try? viewModel.tagsSubject.value() {
            let filteredTags = tags.filter({ tag -> Bool in
                return tag.name.lowercased().contains(text.lowercased())
            })
            viewModel.filteredTagsSubject.onNext(filteredTags)
            questionFormView.tagsField.reloadContents()
        }
    }
}
//swiftlint:enable line_length
