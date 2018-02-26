//
//  EmployeeViewController.swift
//  Life
//
//  Created by Shyngys Kassymov on 21.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Kingfisher
import Material
import Moya
import RxSwift
import RxCocoa
import SnapKit

class EmployeeViewController: UIViewController, ViewModelBased, Stepper {

    private var employeeView: EmployeeView!

    var onUnathorizedError: (() -> Void)?

    typealias ViewModelType = EmployeeViewModel
    var viewModel: EmployeeViewModel!

    private var employee: BehaviorSubject<Employee>?
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        bind()

        viewModel.getEmployeeInfo { [weak self] error in
            guard let `self` = self
                else { return }

            if let moyaError = error as? MoyaError,
                moyaError.response?.statusCode == 401,
                let onUnathorizedError = self.onUnathorizedError {
                onUnathorizedError()
            } else {
                self.employee?.onNext(self.viewModel.employee)
            }
        }
    }

    // MARK: - Bind

    private func bind() {
        employee = BehaviorSubject<Employee>(value: viewModel.employee)
        employee?.asObservable().subscribe(onNext: { [weak self] employee in
            guard let `self` = self else { return }

            self.employeeView.fullname = employee.fullname
            self.employeeView.image = employee.code
            self.employeeView.position = employee.jobPosition
            self.employeeView.login = employee.login
            self.employeeView.birthdate = employee.birthDate.prettyDateString(format: "dd MMMM yyyy")
            self.employeeView.chief = "-"
            self.employeeView.phone = employee.mobilePhoneNumber
            self.employeeView.email = employee.email
        }).disposed(by: disposeBag)
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
            let telUrl = "telprompt://\(self.viewModel.employee.mobilePhoneNumber)"
            if let url = URL(string: telUrl) {
                UIApplication.shared.openURL(url)
            }
        }
        employeeView.didTapEmailButton = {
            if let url = URL(string: "mailto:\(self.viewModel.employee.email)") {
                UIApplication.shared.openURL(url)
            }
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
