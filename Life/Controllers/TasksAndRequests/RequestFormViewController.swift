//
//  RequestFormViewController.swift
//  Life
//
//  Created by Shyngys Kassymov on 23.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import FileProvider
import RxSwift
import RxCocoa
import SnapKit

class RequestFormViewController: UIViewController, Stepper {

    private(set) lazy var requestFormView = RequestFormView(frame: .zero)
    private(set) var viewModel: RequestFormViewModel

    let disposeBag = DisposeBag()

    var didCreateRequest: (() -> Void)?

    init(viewModel: RequestFormViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    // MARK: - Methods

    private func pickAttachments() {
        let fileExplorer = FileExplorerViewController()
        fileExplorer.canChooseFiles = true
        fileExplorer.allowsMultipleSelection = true
        fileExplorer.delegate = self
        fileExplorer.fileFilters = [
            Filter.extension("png"),
            Filter.extension("jpg"),
            Filter.extension("jpeg")
        ]
        self.present(fileExplorer, animated: true, completion: nil)
    }

    // MARK: - UI

    private func setupUI() {
        view.backgroundColor = .white

        setupQuestionFormView()
    }

    private func setupQuestionFormView() {
        requestFormView.didTapCloseButton = {
            self.step.accept(AppStep.createRequestDone)
        }
        requestFormView.didTapAttachmentButton = {
            print("Adding attachments ...")
        }
        requestFormView.didTapSendButton = { [weak self] in
            self?.view.endEditing(true)
            self?.viewModel.createRequest()
        }

        let allCategories = Request.Category.all
        let items = allCategories.map { $0.name }
        let selectedIdx = allCategories.index(of: viewModel.category) ?? 0
        requestFormView.categoryField.setAsPicker(with: items, setText: true, selectedIdx: selectedIdx)
        requestFormView.categoryField.pickerView.selectRow(selectedIdx, inComponent: 0, animated: false)

        view.addSubview(requestFormView)
        requestFormView.snp.makeConstraints { (make) in
            make.top.equalTo(self.topLayoutGuide.snp.bottom)
            make.left.equalTo(self.view)
            make.bottom.equalTo(self.view)
            make.right.equalTo(self.view)
        }

        bindTextField()
        bindEndDateField()
        bindAttachmentButton()
        bindSendButton()
        bindOnRequestFinish()
    }

    private func bindOnRequestFinish() {
        viewModel.requestCreatedSubject.subscribe(onNext: { [weak self] statusCode in
            guard let `self` = self else { return }
            if statusCode == 200 {
                self.step.accept(AppStep.createRequestDone)
                if let didCreateRequest = self.didCreateRequest {
                    didCreateRequest()
                }
            }
        }).disposed(by: disposeBag)
        viewModel.requestCreatedWithErrorSubject.subscribe(onNext: { [weak self] error in
            guard let `self` = self else { return }
            let errorMessages = error.parseMessages()
            if let key = errorMessages.keys.first,
                let message = errorMessages[key] {
                self.showToast(message)
            }
        }).disposed(by: disposeBag)
    }

    private func bindTextField() {
        requestFormView.textField.rx
            .text
            .orEmpty
            .bind(to: viewModel.requestText)
            .disposed(by: disposeBag)
    }

    private func bindEndDateField() {
        requestFormView.endDateField.rx
            .text
            .orEmpty
            .subscribe(onNext: { [weak self] text in
                guard let `self` = self else { return }
                let date = self.requestFormView.endDateField.dateFormatter.date(from: text) ?? Date()
                self.viewModel.dueDate.onNext(date)
            })
            .disposed(by: disposeBag)
    }

    private func bindAttachmentButton() {
        requestFormView.addAttachmentButton.rx.tap.asDriver().throttle(0.5).drive(onNext: { [weak self] in
            self?.pickAttachments()
        }).disposed(by: disposeBag)
    }

    private func bindSendButton() {
        viewModel.requestCreateIsPendingSubject.subscribe(onNext: { [weak self] isPending in
            guard let `self` = self else { return }
            self.requestFormView.sendButton.buttonState = isPending ? .loading : .normal
        }).disposed(by: disposeBag)
    }

}

extension RequestFormViewController: FileExplorerViewControllerDelegate {
    func fileExplorerViewControllerDidFinish(_ controller: FileExplorerViewController) {
        print("File explorer did finish ...")
    }

    func fileExplorerViewController(_ controller: FileExplorerViewController, didChooseURLs urls: [URL]) {
        print("Attached files with urls - \(urls)")
        viewModel.attachments.onNext(urls)
    }
}
