//
//  EmployeeViewController.swift
//  Life
//
//  Created by Shyngys Kassymov on 21.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa
import SnapKit

class EmployeeViewController: UIViewController, ViewModelBased, Stepper {

    private var employeeView: EmployeeView!

    typealias ViewModelType = EmployeeViewModel
    var viewModel: EmployeeViewModel!

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        bind()
    }

    // MARK: - Bind

    private func bind() {
    }

    // MARK: - UI

    private func setupUI() {
        view.backgroundColor = .white

        setupEmployeeView()
    }

    private func setupEmployeeView() {
        employeeView = EmployeeView(frame: .zero)
        employeeView.didTapCloseButton = { [weak self] in
            self?.step.accept(AppStep.employeeDone)
        }
        employeeView.didTapCallButton = {
            print("Calling the employee ...")
        }
        view.addSubview(employeeView)
        employeeView.snp.makeConstraints({ [weak self] (make) in
            guard let `self` = self else { return }
            make.top.equalTo(self.topLayoutGuide.snp.bottom)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
        })
    }

}
