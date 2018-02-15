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
        let tabbarController = AppTabBarController()

        let biBoardVC = BIBoardViewController.instantiate(withViewModel: BIBoardViewModel())
        let biBoardFlow = BIBoardFlow(viewController: biBoardVC)

        let biOfficeVC = BIOfficeViewController.instantiate(withViewModel: BIOfficeViewModel())
        let biOfficeFlow = BIOfficeFlow(viewController: biOfficeVC)

        let lentaVC = LentaViewController.instantiate(withViewModel: LentaViewModel())
        let lentaFlow = LentaFlow(viewController: lentaVC)

        let employeesVC = EmployeesViewController.instantiate(withViewModel: EmployeesViewModel())
        let employeesFlow = EmployeesFlow(viewController: employeesVC)

        let menuVC = MenuViewController.instantiate(withViewModel: MenuViewModel())
        let menuFlow = MenuFlow(viewController: menuVC)

        Flows.whenReady(
            flow1: biBoardFlow,
            flow2: biOfficeFlow,
            flow3: lentaFlow,
            flow4: employeesFlow,
            flow5: menuFlow) { (nav1, nav2, nav3, nav4, nav5) in
                tabbarController.viewControllers = [nav1, nav2, nav3, nav4, nav5]
                let navVC = AppToolbarController(rootViewController: tabbarController)
                self.rootWindow.rootViewController = navVC
        }

        let flowItems = [
            NextFlowItem(
                nextPresentable: biBoardFlow,
                nextStepper: OneStepper(withSingleStep: AppStep.biBoard)
            ),
            NextFlowItem(
                nextPresentable: biOfficeFlow,
                nextStepper: OneStepper(withSingleStep: AppStep.biOffice)
            ),
            NextFlowItem(
                nextPresentable: lentaFlow,
                nextStepper: OneStepper(withSingleStep: AppStep.lenta)
            ),
            NextFlowItem(
                nextPresentable: employeesFlow,
                nextStepper: OneStepper(withSingleStep: AppStep.employees)
            ),
            NextFlowItem(
                nextPresentable: menuFlow,
                nextStepper: OneStepper(withSingleStep: AppStep.menu)
            )
        ]
        return NextFlowItems.multiple(flowItems: flowItems)
    }

}
