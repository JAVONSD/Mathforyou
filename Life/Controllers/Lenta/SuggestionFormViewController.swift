//
//  SuggestionFormViewController.swift
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

class SuggestionFormViewController: UIViewController, Stepper {

    private(set) lazy var suggestionFormView = SuggestionFormView(frame: .zero)

    private let viewModel = SuggestionFormViewModel()

    private var selectedImage: UIImage?
    var didAddSuggestion: ((Suggestion, ImageSize) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        loadTags()
    }

    // MARK: - Methods

    private func loadTags() {
        viewModel.isLoadingTagsSubject.subscribe(onNext: { [weak self] isLoadingTags in
            guard let `self` = self else { return }
            if self.suggestionFormView.tagsField.isFirstResponder {
                self.suggestionFormView.tagsField.setLoading(isLoadingTags)
            }
        }).disposed(by: disposeBag)
        viewModel.getTags()
        viewModel.tagsSubject.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            if let tableView = self.suggestionFormView.tagsField.tableView {
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

        setupSuggestionFormView()
    }

    private func setupSuggestionFormView() {
        suggestionFormView.didTapCloseButton = {
            self.step.accept(AppStep.createSuggestionDone)
        }
        suggestionFormView.didTapCoverImageButton = { [weak self] in
            self?.pickCoverImage(pickingMainImage: true)
        }
        suggestionFormView.didTapAttachmentButton = { [weak self] in
            self?.pickAttachments()
        }
        suggestionFormView.attachmentsView.didTapAdd = { [weak self] in
            self?.pickAttachments()
        }
        view.addSubview(suggestionFormView)
        suggestionFormView.snp.makeConstraints { (make) in
            make.top.equalTo(self.topLayoutGuide.snp.bottom)
            make.left.equalTo(self.view)
            make.bottom.equalTo(self.view)
            make.right.equalTo(self.view)
        }

        bindTitleField()
        bindTextView()
        bindTags()
        bindSendButton()
    }

    private func bindTitleField() {
        suggestionFormView.topicField
            .rx
            .text
            .orEmpty
            .bind(to: viewModel.titleSubject)
            .disposed(by: disposeBag)
    }

    private func bindTextView() {
        suggestionFormView.textField
            .rx
            .text
            .orEmpty
            .bind(to: viewModel.textSubject)
            .disposed(by: disposeBag)
    }

    private func bindTags() {
        suggestionFormView.didDeleteTag = { [weak self] tagText in
            guard let `self` = self else { return }
            self.viewModel.userTags = self.viewModel.userTags.filter({ tag -> Bool in
                return tag.name != tagText
            })
            self.viewModel.userAddedTags.remove(tagText)
        }
        suggestionFormView.didTapAddTag = { [weak self] in
            if let text = self?.suggestionFormView.tagsField.text,
                !text.isEmpty {
                self?.viewModel.userAddedTags.insert(text)
                self?.suggestionFormView.tagsCollectionView.addTag(text)
                self?.suggestionFormView.tagsField.text = nil
                self?.suggestionFormView.tagsField.insertText("")
            }
        }

        suggestionFormView.tagsField.autoSuggestionDataSource = self
        suggestionFormView.tagsField.observeChanges()

        let emptyView = UIView()
        let label = UILabel()
        label.text = NSLocalizedString("no_matches", comment: "")
        label.font = App.Font.body
        label.textAlignment = .center
        label.textColor = App.Color.steel
        emptyView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.edges.equalTo(emptyView)
        }
        suggestionFormView.tagsField.emptyView = emptyView

        suggestionFormView.tagsField.keyboardDistanceFromTextField = 50
    }

    private func bindSendButton() {
        
        suggestionFormView.sendButton
            .rx
            .tap
            .throttle(0.5, scheduler: MainScheduler.instance)
            .withLatestFrom(viewModel.isLoadingSubject)
            .filter { !$0 }
            .subscribe(onNext: { [weak self] _ in
                self?.view.endEditing(true)

                self?.viewModel.attachments = self?.suggestionFormView.attachmentsView
                    .attachments.map { $0.url } ?? []

                self?.viewModel.createSuggestion()
            })
            .disposed(by: disposeBag)
        
        //----
        
        viewModel.isLoadingSubject.skip(1).subscribe(onNext: { [weak self] isLoading in
            self?.suggestionFormView.sendButton.buttonState = isLoading ? .loading : .normal
        }).disposed(by: disposeBag)
        
        //---
        
        viewModel.suggestionCreatedSubject.subscribe(onNext: {[weak self] suggestion in
            if let didAddSuggestion = self?.didAddSuggestion {
                var imageSize = ImageSize.init(width: 0, height: 0)
                if let image = self?.selectedImage {
                    imageSize = ImageSize.init(
                        width: Int(image.size.width),
                        height: Int(image.size.height)
                    )
                }
                didAddSuggestion(suggestion, imageSize)
            }
            self?.step.accept(AppStep.createSuggestionDone)
        }).disposed(by: disposeBag)
        
        //---
        
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
extension SuggestionFormViewController: IQMediaPickerControllerDelegate, UINavigationControllerDelegate {
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

                                suggestionFormView.set(coverImage: image)
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
            suggestionFormView.addAttachments(
                with: attachments,
                isImage: true
            )
        }
    }

    func mediaPickerControllerDidCancel(_ controller: IQMediaPickerController) {
        print("Media pick cancelled ...")
    }
}

extension SuggestionFormViewController: FileExplorerViewControllerDelegate {
    func fileExplorerViewControllerDidFinish(_ controller: FileExplorerViewController) {
        print("File explorer did finish ...")
    }

    func fileExplorerViewController(_ controller: FileExplorerViewController, didChooseURLs urls: [URL]) {
        print("Attached files with urls - \(urls)")
        viewModel.attachments = urls
    }
}

extension SuggestionFormViewController: UITextFieldAutoSuggestionDataSource {
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
            suggestionFormView.tagsCollectionView.addTag(tags[indexPath.row].name)
            suggestionFormView.tagsField.text = nil
        }
    }

    func autoSuggestionField(_ field: UITextField!, textChanged text: String!) {
        let tags = viewModel.tags
        let filteredTags = tags.filter({ tag -> Bool in
            return tag.name.lowercased().contains(text.lowercased())
        })
        viewModel.filteredTags = filteredTags
        suggestionFormView.tagsField.reloadContents()
    }
}
//swiftlint:enable line_length
