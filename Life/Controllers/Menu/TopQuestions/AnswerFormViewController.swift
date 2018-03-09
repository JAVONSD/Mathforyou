//
//  AnswerFormViewController.swift
//  Life
//
//  Created by Shyngys Kassymov on 07.03.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import IGListKit
import RxSwift
import RxCocoa
import SnapKit

class AnswerFormViewController: UIViewController {

    private var answerFormView: AnswerFormView!

    private(set) unowned var questionsViewModel: QuestionsViewModel
    private(set) unowned var answersViewModel: AnswersViewModel

    private let disposeBag = DisposeBag()
    private let dataSource =
        RxTableViewSectionedReloadDataSource<SectionModel<QuestionsViewModel, QuestionItemViewModel>>(
            configureCell: { (_, tv, _, element) in
                let cellId = App.CellIdentifier.checkboxCellId

                let someCell = tv.dequeueReusableCell(withIdentifier: cellId) as? CheckboxCell
                guard let cell = someCell else {
                    return CheckboxCell(style: .default, reuseIdentifier: cellId)
                }

                cell.titleLabel.text = element.question.text

                return cell
        }
    )

    init(questionsViewModel: QuestionsViewModel, answersViewModel: AnswersViewModel) {
        self.questionsViewModel = questionsViewModel
        self.answersViewModel = answersViewModel
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
        let dataSource = self.dataSource

        let items = Observable.just(
            [SectionModel(model: questionsViewModel, items: questionsViewModel.questions)]
        )

        items
            .bind(to: answerFormView.tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        answerFormView.tableView.rx
            .itemSelected
            .map { indexPath in
                return (indexPath, dataSource[indexPath])
            }
            .subscribe(onNext: { pair in
                print("Tapped `\(pair.1)` @ \(pair.0)")
            })
            .disposed(by: disposeBag)

        answerFormView.tableView.rx
            .setDelegate(answerFormView)
            .disposed(by: disposeBag)
    }

    // MARK: - UI

    private func setupUI() {
        view.backgroundColor = .white

        setupTaskAndRequestsView()
    }

    private func setupTaskAndRequestsView() {
        answerFormView = AnswerFormView(isVideo: false)
        view.addSubview(answerFormView)
        answerFormView.snp.makeConstraints({ [weak self] (make) in
            guard let `self` = self else { return }
            make.top.equalTo(self.topLayoutGuide.snp.bottom)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
        })
    }

}
