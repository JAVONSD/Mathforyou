//
//  LoginFlow.swift
//  Life
//
//  Created by Shyngys Kassymov on 14.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material

class LoginFlow: Flow {

    var root: Presentable {
        return self.rootViewController
    }

    private var rootViewController: UINavigationController

    init(rootViewController: UINavigationController) {
        self.rootViewController = rootViewController
    }

    func navigate(to step: Step) -> NextFlowItems {
        guard let step = step as? AppStep else { return NextFlowItems.stepNotHandled }

        switch step {
        case .login:
            return navigateToLoginScreen()
        case .unauthorized:
            return navigateToLoginScreen(isUnauthorized: true)
        case .forgotPassword(let login):
            return navigateToForgotPasswordScreen(login)
        case .forgotPasswordCancel:
            self.rootViewController.presentedViewController?.dismiss(animated: true)
            return NextFlowItems.none
        case .resetPassword:
            return navigateToResetPasswordScreen()
        default:
            return NextFlowItems.stepNotHandled
        }
    }

    private func navigateToLoginScreen(isUnauthorized: Bool = false) -> NextFlowItems {
        let viewController = LoginViewController.instantiate(withViewModel: LoginViewModel())
        viewController.isUnauthorized = isUnauthorized
        self.rootViewController.pushViewController(viewController, animated: true)
        return NextFlowItems.one(
            flowItem: NextFlowItem(
                nextPresentable: viewController,
                nextStepper: viewController)
        )
    }

    private func navigateToForgotPasswordScreen(_ login: String) -> NextFlowItems {
        let viewController = ForgotPasswordViewController.instantiate(
            withViewModel: ForgotPasswordViewModel(login: login)
        )
        self.rootViewController.present(viewController, animated: true, completion: nil)
        return NextFlowItems.one(
            flowItem: NextFlowItem(
                nextPresentable: viewController,
                nextStepper: viewController)
        )
    }

    private func navigateToResetPasswordScreen() -> NextFlowItems {
        let viewController = ResetPasswordViewController.instantiate(withViewModel: ResetPasswordViewModel())
        self.rootViewController.pushViewController(viewController, animated: true)
        return NextFlowItems.none
    }

}
