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
    var isUnauthorized = false

    private let disposeBag = DisposeBag()

    private var loginView: LoginView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        observeChanges()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if isUnauthorized {
            showToast(NSLocalizedString("you_are_unathorized_message", comment: ""))

            isUnauthorized = false
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Actions

    private func helpPressedHandler() {
        let alert = UIAlertController(
            title: NSLocalizedString("help", comment: ""),
            message: NSLocalizedString("forgot_password_instructions", comment: ""),
            preferredStyle: .alert
        )
        alert.popoverPresentationController?.sourceView = view

        let helpAction = UIAlertAction(
            title: NSLocalizedString("call", comment: ""),
            style: .default, handler: { _ in
                if let url = URL(string: "telprompt://+77172918989") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        )
        alert.addAction(helpAction)

        let cancelAction = UIAlertAction(
            title: NSLocalizedString("cancel", comment: ""),
            style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    // MARK: - UI

    private func setupUI() {
        loginView = LoginView(frame: .zero)
        loginView.didTapLogin = { [weak self] (login, password) in
            self?.login(login, password: password)
        }
        loginView.didTapForgotPassword = { [weak self] (login) in
            guard let `self` = self else { return }
            self.helpPressedHandler()
//            self.step.accept(AppStep.forgotPassword(login: login))
        }
        view.addSubview(loginView)
        loginView.snp.makeConstraints({ [weak self] (make) in
            guard let `self` = self else { return }
            make.edges.equalTo(self.view)
        })

        loginView.phoneField?.text = User.current.login
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
            User.current.token = user.token
            User.current.login = user.login
            User.current.employeeCode = user.employeeCode
            User.current.roles = user.roles
            User.current.save()
        }

        if User.current.isAuthenticated {
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
