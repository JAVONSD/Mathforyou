//
//  MainMenuFlow.swift
//  Life
//
//  Created by Shyngys Kassymov on 15.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material

class MainMenuFlow: Flow {

    var root: Presentable {
        return self.rootViewController
    }

    private let rootViewController: AppToolbarController
    private let tabBarController: AppTabBarController

    init(tabBarController: AppTabBarController) {
        self.tabBarController = tabBarController
        self.rootViewController = AppToolbarController(rootViewController: self.tabBarController)
    }

    func navigate(to step: Step) -> NextFlowItems {
        guard let step = step as? AppStep else { return NextFlowItems.stepNotHandled }

        switch step {
        case .login:
            return navigationToLoginScreen()
        case .mainMenu:
            return navigationToMainMenuScreen()
        case .profile:
            return navigationToProfileScreen()
        default:
            return NextFlowItems.stepNotHandled
        }
    }

    private func navigateToLoginScreen(isUnathorized: Bool = false) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let step = isUnathorized ? AppStep.unauthorized : AppStep.login
            appDelegate.coordinator.coordinate(
                flow: appDelegate.appFlow,
                withStepper: OneStepper(withSingleStep: step)
            )
        }
    }

    private func navigationToLoginScreen() -> NextFlowItems {
        navigateToLoginScreen()
        return NextFlowItems.none
    }

    private func navigationToMainMenuScreen() -> NextFlowItems {
        let biBoardVC = BIBoardViewController.instantiate(withViewModel: BIBoardViewModel())
        biBoardVC.onUnathorizedError = {
            self.navigateToLoginScreen(isUnathorized: true)
        }

        let biOfficeVC = BIOfficeViewController.instantiate(withViewModel: BIOfficeViewModel())
        biOfficeVC.onUnathorizedError = {
            self.navigateToLoginScreen(isUnathorized: true)
        }

        let lentaVC = LentaViewController()
        lentaVC.onUnathorizedError = {
            self.navigateToLoginScreen(isUnathorized: true)
        }

        let stuffVC = StuffViewController.configuredVC
        stuffVC.onUnathorizedError = {
            self.navigateToLoginScreen(isUnathorized: true)
        }

        let menuVC = MenuViewController.instantiate(withViewModel: MenuViewModel())
        menuVC.onUnathorizedError = {
            self.navigateToLoginScreen(isUnathorized: true)
        }

        tabBarController.viewControllers = [
            biBoardVC,
            biOfficeVC,
            lentaVC,
            stuffVC,
            menuVC
        ]

        return NextFlowItems.one(flowItem: NextFlowItem(
            nextPresentable: tabBarController,
            nextStepper: tabBarController
        ))
    }

    private func navigationToProfileScreen() -> NextFlowItems {
        let viewController = ProfileViewController.configuredVC
        self.rootViewController.pushViewController(viewController, animated: true)
        return NextFlowItems.none
    }

}
