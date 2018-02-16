//
//  AppFlow.swift
//  Life
//
//  Created by Shyngys Kassymov on 14.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit

class AppFlow: Flow {

    var root: Presentable {
        return self.rootWindow
    }

    private let rootWindow: UIWindow

    init(window: UIWindow) {
        self.rootWindow = window
    }

    func navigate(to step: Step) -> NextFlowItems {
        guard let step = step as? AppStep else { return NextFlowItems.stepNotHandled }

        switch step {
        case .login:
            return navigationToLoginScreen()
        case .mainMenu:
            return navigationToMainMenuScreen()
        default:
            return NextFlowItems.stepNotHandled
        }
    }

    private func navigationToLoginScreen () -> NextFlowItems {
        let navVC = UINavigationController()
        navVC.setNavigationBarHidden(true, animated: false)
        let loginFlow = LoginFlow(rootViewController: navVC)

        Flows.whenReady(flow1: loginFlow) { (navigationController: UINavigationController) in
            self.rootWindow.rootViewController = navigationController
        }

        return NextFlowItems.one(
            flowItem: NextFlowItem(
                nextPresentable: loginFlow,
                nextStepper: OneStepper(withSingleStep: AppStep.login)
            )
        )
    }

    private func navigationToMainMenuScreen () -> NextFlowItems {
        let tabBar = AppTabBarController()
        let mainMenuFlow = MainMenuFlow(tabBarController: tabBar)

        Flows.whenReady(
            flow1: mainMenuFlow) { nav1 in
                self.rootWindow.rootViewController = nav1
        }

        return NextFlowItems.one(flowItem: NextFlowItem(
            nextPresentable: mainMenuFlow,
            nextStepper: OneStepper(withSingleStep: AppStep.mainMenu)
        ))
    }

}
