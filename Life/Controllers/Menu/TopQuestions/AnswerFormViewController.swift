//
//  AnswerFormViewController.swift
//  Life
//
//  Created by Shyngys Kassymov on 07.03.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import IGListKit
import IQMediaPickerController
import Photos
import RxSwift
import RxCocoa
import SnapKit

class AnswerFormViewController: UIViewController, Stepper {

    private var answerFormView: AnswerFormView!
    var didCreateAnswer: ((Answer, [String]) -> Void)?

    private(set) var viewModel: AnswerFormViewModel

    private let disposeBag = DisposeBag()

    init(viewModel: AnswerFormViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        bind()
    }

    // MARK: - Bind

    private func bind() {
        let dataSource =
            RxTableViewSectionedReloadDataSource<SectionModel<String, Question>>(
                configureCell: { (_, tv, _, element) in
                    let cellId = App.CellIdentifier.checkboxCellId

                    let someCell = tv.dequeueReusableCell(withIdentifier: cellId) as? CheckboxCell
                    guard let cell = someCell else {
                        return CheckboxCell(style: .default, reuseIdentifier: cellId)
                    }

                    cell.titleLabel.text = element.text
                    cell.set(selected: self.viewModel.pickedQuestions.value.contains(element))

                    return cell
            }
        )

        let items = viewModel.pickedQuestions.asObservable()
            .map { _ -> [SectionModel<String, Question>] in
                return [SectionModel(model: "", items: self.viewModel.questions)]
            }

        items
            .bind(to: answerFormView.tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        answerFormView.tableView.rx
            .itemSelected
            .map { indexPath in
                return (indexPath, dataSource[indexPath])
            }
            .subscribe(onNext: { pair in
                if pair.0.row < self.viewModel.questions.count {
                    let question = self.viewModel.questions[pair.0.row]
                    var pickedQuestions = self.viewModel.pickedQuestions.value
                    if !self.viewModel.isVideo {
                        pickedQuestions.removeAll()
                        pickedQuestions.insert(question)
                    } else {
                        if pickedQuestions.contains(question) {
                            pickedQuestions.remove(question)
                        } else {
                            pickedQuestions.insert(question)
                        }
                    }
                    self.viewModel.pickedQuestions.accept(pickedQuestions)
                }
            })
            .disposed(by: disposeBag)

        answerFormView.tableView.rx
            .setDelegate(answerFormView)
            .disposed(by: disposeBag)
    }

    // MARK: - Actions & Methods

    private func pickVideo() {
        let alert = UIAlertController(
            title: NSLocalizedString("choose_option", comment: ""),
            message: nil,
            preferredStyle: .actionSheet
        )
        alert.popoverPresentationController?.sourceView = view

        let captureAction = UIAlertAction(
            title: NSLocalizedString("capture_video", comment: ""),
            style: .default) { [weak self] _ in
                self?.pickVideo(fromLibrary: false)
        }
        alert.addAction(captureAction)
        let libraryAction = UIAlertAction(
            title: NSLocalizedString("pick_from_gallery", comment: ""),
            style: .default) { [weak self] _ in
                self?.pickVideo(fromLibrary: true)
        }
        alert.addAction(libraryAction)
        let cancelAction = UIAlertAction(
            title: NSLocalizedString("cancel", comment: ""),
            style: .cancel,
            handler: nil)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    private func pickVideo(fromLibrary: Bool) {
        let vc = IQMediaPickerController()
        vc.allowsPickingMultipleItems = false
        vc.delegate = self
        vc.mediaTypes = [
            NSNumber(value: IQMediaPickerControllerMediaType.video.rawValue)
        ]
        vc.sourceType = fromLibrary ? .library : .cameraMicrophone
        present(vc, animated: true, completion: nil)
    }

    func getDataFromAsset(at url: URL) {
        let fetchResult = PHAsset.fetchAssets(withALAssetURLs: [url], options: nil)
        if let phAsset = fetchResult.firstObject {
            PHImageManager.default().requestAVAsset(
                forVideo: phAsset,
                options: PHVideoRequestOptions(),
                resultHandler: { (asset, _, _) -> Void in
                if let asset = asset as? AVURLAsset {
                    let videoData = try? Data(contentsOf: asset.url)

                    let videoPath = NSTemporaryDirectory() + "tmpMovie.MOV"
                    let videoURL = URL(fileURLWithPath: videoPath)
                    let writeResult = try? videoData?.write(to: videoURL)

                    if writeResult != nil {
                        self.viewModel.videoFile = videoURL
                    }
                }
            })
        }
    }

    // MARK: - UI

    private func setupUI() {
        view.backgroundColor = .white

        setupTaskAndRequestsView()
    }

    private func setupTaskAndRequestsView() {
        answerFormView = AnswerFormView(isVideo: viewModel.isVideo)
        view.addSubview(answerFormView)
        answerFormView.snp.makeConstraints({ [weak self] (make) in
            guard let `self` = self else { return }
            make.top.equalTo(self.topLayoutGuide.snp.bottom)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
        })

        bindCloseButton()
        if viewModel.isVideo {
            bindVideoButton()
        } else {
            bindTextField()
        }
        bindResults()
    }

    private func bindCloseButton() {
        answerFormView.headerView.closeButton?.rx.tap.asDriver().drive(onNext: { [weak self] in
            self?.step.accept(AppStep.createAnswerDone)
        }).disposed(by: disposeBag)
    }

    private func bindVideoButton() {
        answerFormView.videoAnswerView.chooseVideoButton.rx.tap.asDriver().drive(onNext: { [weak self] in
            self?.pickVideo()
        }).disposed(by: disposeBag)

        answerFormView.videoAnswerView.sendButton.rx.tap.asDriver().drive(onNext: { [weak self] in
            self?.viewModel.createAnswer()
        }).disposed(by: disposeBag)
        viewModel.isLoadingSubject.skip(1).subscribe(onNext: { [weak self] isLoading in
            self?.answerFormView.videoAnswerView.sendButton.buttonState = isLoading ? .loading : .normal
        }).disposed(by: disposeBag)
    }

    private func bindTextField() {
        answerFormView.answerView.textField.rx
            .text
            .orEmpty
            .bind(to: viewModel.answerText)
            .disposed(by: disposeBag)

        answerFormView.answerView.sendButton.rx.tap.asDriver().drive(onNext: { [weak self] in
            self?.view.endEditing(true)
            self?.viewModel.createAnswer()
        }).disposed(by: disposeBag)
        viewModel.isLoadingSubject.skip(1).subscribe(onNext: { [weak self] isLoading in
            self?.answerFormView.answerView.sendButton.buttonState = isLoading ? .loading : .normal
        }).disposed(by: disposeBag)
    }

    private func bindResults() {
        viewModel.answerCreatedSubject.subscribe(onNext: {[weak self] answer in
            if let didCreateAnswer = self?.didCreateAnswer {
                didCreateAnswer(answer, self?.viewModel.pickedQuestions.value.map { $0.id } ?? [])
            }
            self?.step.accept(AppStep.createAnswerDone)
        }).disposed(by: disposeBag)
        viewModel.videoAnswerCreatedSubject.subscribe(onNext: {[weak self] answer in
            let json = [
                "authorCode": User.current.employeeCode,
                "authorName": User.current.profile?.fullname ?? "",
                "jobPosition": User.current.profile?.jobPosition ?? "",
                "createDate": Date().serverDate
            ]

            if let didCreateAnswer = self?.didCreateAnswer,
                let answer = try? JSONDecoder().decode(Answer.self, from: json.toJSONData()) {
                didCreateAnswer(answer, self?.viewModel.pickedQuestions.value.map { $0.id } ?? [])
            }
            self?.step.accept(AppStep.createAnswerDone)
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

extension AnswerFormViewController: IQMediaPickerControllerDelegate, UINavigationControllerDelegate {
    func mediaPickerController(_ controller: IQMediaPickerController,
                               didFinishMediaWithInfo info: [AnyHashable : Any]) {
        if let key = info.keys.first as? String,
            let dicts = info[key] as? [[String: Any]],
            let dict = dicts.first,
            let videoFile = dict[IQMediaAssetURL] as? URL {
            self.getDataFromAsset(at: videoFile)
        }
    }

    func mediaPickerControllerDidCancel(_ controller: IQMediaPickerController) {
        print("Media pick cancelled ...")
    }
}
