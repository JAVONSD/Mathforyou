//
//  QuestionFormViewController.swift
//  Life
//
//  Created by Shyngys Kassymov on 23.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import SnapKit

class QuestionFormViewController: UIViewController, Stepper {

    private(set) lazy var questionFormView = QuestionFormView(frame: .zero)

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    // MARK: - UI

    private func setupUI() {
        view.backgroundColor = .white

        setupQuestionFormView()
    }

    private func setupQuestionFormView() {
        questionFormView.didTapCloseButton = {
            self.step.accept(AppStep.createQuestionDone)
        }
        questionFormView.didTapAddButton = {
            print("Adding the question ...")
        }
        view.addSubview(questionFormView)
        questionFormView.snp.makeConstraints { (make) in
            make.top.equalTo(self.topLayoutGuide.snp.bottom)
            make.left.equalTo(self.view)
            make.bottom.equalTo(self.view)
            make.right.equalTo(self.view)
        }
    }

}
