//
//  SuggestionFormViewController.swift
//  Life
//
//  Created by Shyngys Kassymov on 23.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import SnapKit

class SuggestionFormViewController: UIViewController, Stepper {

    private(set) lazy var suggestionFormView = SuggestionFormView(frame: .zero)

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
        suggestionFormView.didTapCloseButton = {
            self.step.accept(AppStep.createSuggestionDone)
        }
        suggestionFormView.didTapAttachmentButton = {
            print("Adding attachments ...")
        }
        suggestionFormView.didTapSendButton = {
            print("Sending new request ...")
        }
        view.addSubview(suggestionFormView)
        suggestionFormView.snp.makeConstraints { (make) in
            make.top.equalTo(self.topLayoutGuide.snp.bottom)
            make.left.equalTo(self.view)
            make.bottom.equalTo(self.view)
            make.right.equalTo(self.view)
        }
    }

}
