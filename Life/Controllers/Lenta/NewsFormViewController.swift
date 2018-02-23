//
//  NewsFormViewController.swift
//  Life
//
//  Created by Shyngys Kassymov on 23.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import SnapKit

class NewsFormViewController: UIViewController, Stepper {

    private(set) lazy var newsFormView = NewsFormView(frame: .zero)

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
        newsFormView.didTapCloseButton = {
            self.step.accept(AppStep.createNewsDone)
        }
        newsFormView.didTapCoverImageButton = {
            print("Adding cover image ...")
        }
        newsFormView.didTapAttachmentButton = {
            print("Adding attachments ...")
        }
        newsFormView.didTapMakeAsHistoryButton = {
            print("Toggling history field of this news ...")
        }
        newsFormView.didTapSendButton = {
            print("Sending new request ...")
        }
        view.addSubview(newsFormView)
        newsFormView.snp.makeConstraints { (make) in
            make.top.equalTo(self.topLayoutGuide.snp.bottom)
            make.left.equalTo(self.view)
            make.bottom.equalTo(self.view)
            make.right.equalTo(self.view)
        }
    }

}
