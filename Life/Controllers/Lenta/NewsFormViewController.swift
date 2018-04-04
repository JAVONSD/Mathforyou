//
//  NewsFormViewController.swift
//  Life
//
//  Created by Shyngys Kassymov on 23.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import IQMediaPickerController
import RxSwift
import RxCocoa
import SnapKit
import UITextField_AutoSuggestion

class NewsFormViewController: UIViewController, Stepper {

    private(set) lazy var newsFormView = NewsFormView(frame: .zero)

    private let viewModel = NewsFormViewModel()

    private var selectedImage: UIImage?
    var didAddNews: ((News, ImageSize) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        loadTags()
    }

    // MARK: - Methods

    private func loadTags() {
        viewModel.isLoadingTagsSubject.subscribe(onNext: { [weak self] isLoadingTags in
            guard let `self` = self else { return }
            if self.newsFormView.tagsField.isFirstResponder {
                self.newsFormView.tagsField.setLoading(isLoadingTags)
            }
        }).disposed(by: disposeBag)
        viewModel.getTags()
        viewModel.tagsSubject.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            if let tableView = self.newsFormView.tagsField.tableView {
                tableView.reloadData()
            }
        })
            .disposed(by: disposeBag)
    }

    private func pickCoverImage(pickingMainImage: Bool) {
        viewModel.pickingMainImage = pickingMainImage

        let alert = UIAlertController(
            title: NSLocalizedString("choose_option", comment: ""),
            message: nil,
            preferredStyle: .actionSheet
        )
        alert.popoverPresentationController?.sourceView = view

        let captureAction = UIAlertAction(
            title: NSLocalizedString("capture_photo", comment: ""),
            style: .default) { [weak self] _ in
                self?.pickCoverImage(fromLibrary: false)
            }
        alert.addAction(captureAction)
        let libraryAction = UIAlertAction(
            title: NSLocalizedString("pick_from_gallery", comment: ""),
            style: .default) { [weak self] _ in
                self?.pickCoverImage(fromLibrary: true)
            }
        alert.addAction(libraryAction)
        let cancelAction = UIAlertAction(
            title: NSLocalizedString("cancel", comment: ""),
            style: .cancel,
            handler: nil)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    private func pickCoverImage(fromLibrary: Bool) {
        let vc = IQMediaPickerController()
        vc.allowsPickingMultipleItems = !viewModel.pickingMainImage
        vc.delegate = self
        vc.mediaTypes = [
            NSNumber(value: IQMediaPickerControllerMediaType.photo.rawValue)
        ]
        vc.sourceType = fromLibrary ? .library : .cameraMicrophone
        present(vc, animated: true, completion: nil)
    }

    private func pickAttachments() {
        pickCoverImage(pickingMainImage: false)
    }

    // MARK: - UI

    private func setupUI() {
        view.backgroundColor = .white

        setupQuestionFormView()
    }

    private func setupQuestionFormView() {
        newsFormView.didTapCloseButton = {
            self.step.accept(AppStep.createNewsDone)
        }
        newsFormView.didTapCoverImageButton = { [weak self] in
            self?.pickCoverImage(pickingMainImage: true)
        }
        newsFormView.didTapAttachmentButton = { [weak self] in
            self?.pickAttachments()
        }
        newsFormView.attachmentsView.didTapAdd = { [weak self] in
            self?.pickAttachments()
        }
        view.addSubview(newsFormView)
        newsFormView.snp.makeConstraints { (make) in
            make.top.equalTo(self.topLayoutGuide.snp.bottom)
            make.left.equalTo(self.view)
            make.bottom.equalTo(self.view)
            make.right.equalTo(self.view)
        }

        bindTitleField()
        bindTextView()
        bindTags()
        bindMakeAsHistoryButton()
        bindSendButton()
    }

    private func bindTitleField() {
        newsFormView.titleField
            .rx
            .text
            .orEmpty
            .bind(to: viewModel.titleSubject)
            .disposed(by: disposeBag)
    }

    private func bindTextView() {
        newsFormView.textField
            .rx
            .text
            .orEmpty
            .bind(to: viewModel.textSubject)
            .disposed(by: disposeBag)
    }

    private func bindMakeAsHistoryButton() {
        newsFormView.makeAsHistoryButton
            .rx
            .tap
            .asDriver()
            .drive(onNext: { [weak self] in
                let makeAsHistoryButton = self?.newsFormView.makeAsHistoryButton
                let isHistoryEvent = makeAsHistoryButton?.isSelected ?? false
                makeAsHistoryButton?.isSelected = !isHistoryEvent
                makeAsHistoryButton?.tintColor = !isHistoryEvent ? App.Color.azure : App.Color.coolGrey
                self?.viewModel.isHistoryEvent.onNext(!isHistoryEvent)
            })
            .disposed(by: disposeBag)
    }

    private func bindTags() {
        newsFormView.didDeleteTag = { [weak self] tagText in
            guard let `self` = self else { return }
            self.viewModel.userTags = self.viewModel.userTags.filter({ tag -> Bool in
                return tag.name != tagText
            })
            self.viewModel.userAddedTags.remove(tagText)
        }
        newsFormView.didTapAddTag = { [weak self] in
            if let text = self?.newsFormView.tagsField.text,
                !text.isEmpty {
                self?.viewModel.userAddedTags.insert(text)
                self?.newsFormView.tagsCollectionView.addTag(text)
                self?.newsFormView.tagsField.text = nil
                self?.newsFormView.tagsField.insertText("")
            }
        }

        newsFormView.tagsField.autoSuggestionDataSource = self
        newsFormView.tagsField.observeChanges()
    }

    private func bindSendButton() {
        newsFormView.sendButton
            .rx
            .tap
            .throttle(0.5, scheduler: MainScheduler.instance)
            .withLatestFrom(viewModel.isLoadingSubject)
            .filter { !$0 }
            .subscribe(onNext: { [weak self] _ in
                self?.view.endEditing(true)

                self?.viewModel.attachments = self?.newsFormView.attachmentsView
                    .attachments.map { $0.url } ?? []

                self?.viewModel.createNews()
            })
            .disposed(by: disposeBag)
        viewModel.isLoadingSubject.skip(1).subscribe(onNext: { [weak self] isLoading in
            self?.newsFormView.sendButton.buttonState = isLoading ? .loading : .normal
        }).disposed(by: disposeBag)
        viewModel.newsCreatedSubject.subscribe(onNext: {[weak self] news in
            if let didAddNews = self?.didAddNews {
                var imageSize = ImageSize.init(width: 0, height: 0)
                if let image = self?.selectedImage {
                    imageSize = ImageSize.init(
                        width: Int(image.size.width),
                        height: Int(image.size.height)
                    )
                }
                didAddNews(news, imageSize)
            }
            self?.step.accept(AppStep.createNewsDone)
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
extension NewsFormViewController: IQMediaPickerControllerDelegate, UINavigationControllerDelegate {
    func mediaPickerController(_ controller: IQMediaPickerController, didFinishMediaWithInfo info: [AnyHashable : Any]) {
        var attachments = [URL]()

        for key in info.keys where key is String {
            if let dicts = info[key] as? [[String: Any]] {
                for dict in dicts {
                    if let image = dict[IQMediaImage] as? UIImage {
                        if viewModel.pickingMainImage {
                            selectedImage = image
                        }

                        let tempDir = NSTemporaryDirectory()
                        let tempDirPath = URL(fileURLWithPath: tempDir)
                        let imageName = UUID().uuidString
                        let imagePath = tempDirPath.appendingPathComponent("\(imageName).jpg")
                        if FileManager.default.fileExists(atPath: imagePath.path) {
                            try? FileManager.default.removeItem(at: imagePath)
                        }
                        let imageData = UIImageJPEGRepresentation(image, 1.0)
                        do {
                            try imageData?.write(to: imagePath)

                            if viewModel.pickingMainImage {
                                viewModel.coverImage = imagePath

                                newsFormView.set(coverImage: image)
                            } else {
                                attachments.append(imagePath)
                            }
                        } catch {
                            print("Failed to write image at path \(imagePath)")
                        }
                    }
                }
            }
        }

        if !attachments.isEmpty {
            newsFormView.addAttachments(
                with: attachments,
                isImage: true
            )
        }
    }

    func mediaPickerControllerDidCancel(_ controller: IQMediaPickerController) {
        print("Media pick cancelled ...")
    }
}

extension NewsFormViewController: UITextFieldAutoSuggestionDataSource {
    func autoSuggestionField(_ field: UITextField!, tableView: UITableView!, cellForRowAt indexPath: IndexPath!, forText text: String!) -> UITableViewCell! {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: App.CellIdentifier.suggestionCellId)

        let cell = tableView.dequeueReusableCell(withIdentifier: App.CellIdentifier.suggestionCellId, for: indexPath)
        let tags = viewModel.filteredTags
        if tags.count > indexPath.row {
            cell.textLabel?.text = tags[indexPath.row].name
        }
        return cell
    }

    func autoSuggestionField(_ field: UITextField!, tableView: UITableView!, numberOfRowsInSection section: Int, forText text: String!) -> Int {
        return viewModel.filteredTags.count
    }

    func autoSuggestionField(_ field: UITextField!, tableView: UITableView!, didSelectRowAt indexPath: IndexPath!, forText text: String!) {
        let tags = viewModel.filteredTags
        if tags.count > indexPath.row {
            viewModel.userTags.insert(tags[indexPath.row])
            newsFormView.tagsCollectionView.addTag(tags[indexPath.row].name)
            newsFormView.tagsField.text = nil
        }
    }

    func autoSuggestionField(_ field: UITextField!, textChanged text: String!) {
        let tags = viewModel.tags
        let filteredTags = tags.filter({ tag -> Bool in
            return tag.name.lowercased().contains(text.lowercased())
        })
        viewModel.filteredTags = filteredTags
        newsFormView.tagsField.reloadContents()
    }
}
//swiftlint:enable line_length
