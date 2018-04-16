//
//  LoginViewController.swift
//  Life
//
//  Created by Shyngys Kassymov on 11.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import BiometricAuthentication
import KeychainAccess
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

        promptBiometricLoginIfEnabled()
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
                if let url = URL(string: "tel://+77172918989") {
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

        let isOn = UserDefaults.standard.bool(forKey: App.Key.useTouchOrFaceIdToLogin)
        loginView.useTouchIDSwitch.setSwitchState(state: isOn ? .on : .off)
        loginView.useTouchIDSwitch.rx.controlEvent(.valueChanged)
            .asDriver()
            .drive(onNext: { [weak self] in
                let isOn = self?.loginView.useTouchIDSwitch.isOn ?? false
                UserDefaults.standard.set(isOn, forKey: App.Key.useTouchOrFaceIdToLogin)
                UserDefaults.standard.synchronize()
            })
            .disposed(by: disposeBag)

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
                    let saveCredentials = self?.loginView.useTouchIDSwitch.isOn ?? false
                    self?.onLogin(json: json, saveCredentials: saveCredentials)
                case .error(let error):
                    self?.onLogin(error: error)
                }
        })
    }

    private func loginWithSavedCredentials() {
        let keychain = Keychain(service: App.Key.loginCredentialsIdentifier)

        let login = UserDefaults.standard.string(forKey: App.Key.userLogin) ?? ""
        let password = keychain[string: login] ?? ""

        self.loginView.loginButton?.buttonState = .loading
        self.viewModel.login(
            login,
            password: password,
            completion: { [weak self] (response: SingleEvent<Response>) in
                self?.loginView.loginButton?.buttonState = .normal

                switch response {
                case .success(let json):
                    self?.onLogin(json: json, saveCredentials: false)
                case .error(let error):
                    self?.onLogin(error: error)
                }
        })
    }

    private func onLogin(json: Response, saveCredentials: Bool = true) {
        saveUser(json)

        if saveCredentials {
            let login = self.loginView.phoneField?.text ?? ""
            let password = self.loginView.passwordField?.text ?? ""

            let keychain = Keychain(service: App.Key.loginCredentialsIdentifier)
            keychain[login] = password
        }

        if User.current.isAuthenticated {
            step.accept(AppStep.mainMenu)
        }
    }

    private func saveUser(_ json: Response) {
        if let user = try? JSONDecoder().decode(User.self, from: json.data) {
            User.current.token = user.token
            User.current.login = user.login
            User.current.employeeCode = user.employeeCode
            User.current.roles = user.roles
            User.current.save()
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

    private func promptBiometricLoginIfEnabled() {
        guard UserDefaults.standard.bool(forKey: App.Key.useTouchOrFaceIdToLogin) else {
            return
        }

        let isFaceIdAvailable = BioMetricAuthenticator.shared.faceIDAvailable()

        var reason = NSLocalizedString("kTouchIdAuthenticationReason", comment: "")
        if isFaceIdAvailable {
            reason = NSLocalizedString("kFaceIdAuthenticationReason", comment: "")
        }

        let fallbackTitle = NSLocalizedString("enter_manually", comment: "")

        BioMetricAuthenticator.authenticateWithBioMetrics(
            reason: reason,
            fallbackTitle: fallbackTitle,
            success: { [weak self] in
                self?.loginWithSavedCredentials()
            },
            failure: { [weak self] (error) in
                self?.handleBiometric(error: error, isFaceIdAvailable: isFaceIdAvailable)
            }
        )
    }

    private func handleBiometric(error: AuthenticationError, isFaceIdAvailable: Bool, isPasscode: Bool = false) {
        if error == .canceledByUser || error == .canceledBySystem {
            resetSavedUserLoginCredentials()
            return
        } else if error == .biometryNotAvailable {
            let reason = NSLocalizedString("kBiometryNotAvailableReason", comment: "")
            showErrorAlert(reason)
        } else if error == .fallback {
            resetSavedUserLoginCredentials()

            _ = loginView.phoneField?.becomeFirstResponder()
        } else if error == .biometryNotEnrolled {
            var reason = NSLocalizedString("kNoFingerprintEnrolled", comment: "")
            if isFaceIdAvailable {
                reason = NSLocalizedString("kNoFaceIdentityEnrolled", comment: "")
            }

            if isPasscode {
                reason = NSLocalizedString("kSetPasscodeToUseTouchID", comment: "")
                if isFaceIdAvailable {
                    reason = NSLocalizedString("kSetPasscodeToUseFaceID", comment: "")
                }
            }

            showErrorAlert(reason)
        } else if error == .biometryLockedout {
            var reason = NSLocalizedString("kTouchIdPasscodeAuthenticationReason", comment: "")
            if isFaceIdAvailable {
                reason = NSLocalizedString("kFaceIdPasscodeAuthenticationReason", comment: "")
            }

            BioMetricAuthenticator.authenticateWithPasscode(
                reason: reason,
                success: { [weak self] in
                    self?.loginWithSavedCredentials()
                },
                failure: { [weak self] (error) in
                    self?.handleBiometric(error: error, isFaceIdAvailable: isFaceIdAvailable, isPasscode: true)
                }
            )
        } else {
            var reason = NSLocalizedString("kDefaultTouchIDAuthenticationFailedReason", comment: "")
            if isFaceIdAvailable {
                reason = NSLocalizedString("kDefaultFaceIDAuthenticationFailedReason", comment: "")
            }
            showErrorAlert(reason)
        }
    }

    private func resetSavedUserLoginCredentials() {
        UserDefaults.standard.set(false, forKey: App.Key.useTouchOrFaceIdToLogin)
        UserDefaults.standard.synchronize()

        let keychain = Keychain(service: App.Key.loginCredentialsIdentifier)
        try? keychain.removeAll()

        loginView.useTouchIDSwitch.setSwitchState(state: .off)
    }

}
