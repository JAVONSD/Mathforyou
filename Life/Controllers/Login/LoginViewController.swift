//
//  LoginViewController.swift
//  Life
//
//  Created by Shyngys Kassymov on 11.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material
import Moya
import RxSwift
import SnapKit

class LoginViewController: UIViewController, ViewModelBased, Stepper {

    typealias ViewModelType = LoginViewModel

    var viewModel: LoginViewModel!
    private let disposeBag = DisposeBag()

    private var loginView: LoginView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        observeChanges()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - UI

    private func setupUI() {
        loginView = LoginView(frame: .zero)
        loginView.didTapLogin = { [weak self] (login, password) in
            self?.login(login, password: password)
        }
        loginView.didTapForgotPassword = { [weak self] (login) in
            guard let `self` = self else { return }
            self.step.accept(AppStep.forgotPassword(login: login))
        }
        view.addSubview(loginView)
        loginView.snp.makeConstraints({ [weak self] (make) in
            guard let `self` = self else { return }
            make.edges.equalTo(self.view)
        })
    }

    // MARK: - Methods

    private func observeChanges() {
        viewModel.loginErrorMessage
            .asObservable()
            .subscribe(onNext: { [weak self] (errorMessage) in
                self?.loginView.setLogin(error: errorMessage)
            })
            .disposed(by: disposeBag)

        viewModel.passwordErrorMessage
            .asObservable()
            .subscribe(onNext: { [weak self] (errorMessage) in
                self?.loginView.setPassword(error: errorMessage)
            })
            .disposed(by: disposeBag)
    }

    private func login(_ login: String, password: String) {
        self.loginView.loginButton?.buttonState = .loading
        self.viewModel.login(
            login,
            password: password,
            completion: { [weak self] (response: SingleEvent<Response>) in
                self?.loginView.loginButton?.buttonState = .normal

                switch response {
                case .success(let json):
                    self?.onLogin(json: json)
                case .error(let error):
                    self?.onLogin(error: error)
                }
        })
    }

    private func onLogin(json: Response) {
        if let user = try? JSONDecoder().decode(User.self, from: json.data) {
            User.currentUser.token = user.token
            User.currentUser.login = user.login
            User.currentUser.employeeCode = user.employeeCode
            User.currentUser.save()
        }

        if User.currentUser.isAuthenticated {
            self.step.accept(AppStep.mainMenu)
        }
    }

    private func onLogin(error: Error) {
        let errorMessages = error.parseMessages()

        viewModel.loginErrorMessage.accept(errorMessages[App.Field.login])
        viewModel.passwordErrorMessage.accept(errorMessages[App.Field.password])

        if let error = errorMessages[App.Field.default] {
            showToast(error, position: .top)
        }
    }

}
