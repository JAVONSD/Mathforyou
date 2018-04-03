//
//  CongratulateViewController.swift
//  Life
//
//  Created by Shyngys Kassymov on 02.04.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Kingfisher
import RxSwift
import SnapKit

class CongratulateViewController: UIViewController, Stepper {

    private let viewModel: CongratulateViewModel
    private lazy var congratulateView = CongratulateView()

    private let disposeBag = DisposeBag()

    init(viewModel: CongratulateViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBindings()
        setupUI()
    }

    // MARK: - Bindings

    private func setupBindings() {
        viewModel.loading.skip(1)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] loading in
                self?.congratulateView.sendButton.buttonState = loading ? .loading : .normal
            })
            .disposed(by: disposeBag)

        viewModel.onSuccessSubject
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - UI

    private func setupUI() {
        view.addSubview(congratulateView)
        congratulateView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }

        ImageDownloader.set(
            image: "",
            employeeCode: viewModel.employee.code,
            to: congratulateView.headerView.imageView,
            placeholderImage: #imageLiteral(resourceName: "ic-user"),
            size: CGSize(width: 50, height: 50)
        )

        congratulateView.headerView.closeButton?.rx.tap
            .asDriver()
            .throttle(0.5)
            .drive(onNext: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)

        congratulateView.textView.rx.text.orEmpty
            .bind(to: viewModel.text)
            .disposed(by: disposeBag)

        congratulateView.sendButton.rx.tap
            .asDriver()
            .throttle(0.5)
            .drive(onNext: { [weak self] in
                self?.viewModel.congratulate()
            })
            .disposed(by: disposeBag)
    }

}
