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

    private lazy var notificationsViewModel = NotificationsViewModel()
    private lazy var tasksAndRequestsViewModel = TasksAndRequestsViewModel()
    private lazy var stuffViewModel = StuffViewModel()
    private lazy var topQuestionsViewModel = TopQuestionsViewModel()

    var root: Presentable {
        return self.rootViewController
    }

    private let rootViewController: StatusBarController
    private let viewController: AppTabBarController

    init() {
        viewController = AppTabBarController()
        rootViewController = StatusBarController(rootViewController: viewController)
    }

    func navigate(to step: Step) -> NextFlowItems {
        guard let step = step as? AppStep else { return NextFlowItems.stepNotHandled }

        switch step {
        case .mainMenu:
            return navigationToMainMenuScreen()
        default:
            return NextFlowItems.stepNotHandled
        }
    }

    // MARK: - Navigation

    //swiftlint:disable function_body_length
    private func navigationToMainMenuScreen() -> NextFlowItems {
        let biOfficeVC = configuredBIOffice()
        let biOfficeFlow = BIOfficeFlow(
            viewController: biOfficeVC,
            notificationsViewModel: notificationsViewModel,
            tasksAndRequestsViewModel: tasksAndRequestsViewModel,
            employeesViewModel: stuffViewModel.employeesViewModel
        )

        let biBoardVC = configuredBIBoard()
        let biBoardFlow = BIBoardFlow(
            viewController: biBoardVC,
            notificationsViewModel: notificationsViewModel,
            topQuestionsViewModel: topQuestionsViewModel
        )

        let lentaVC = configuredLenta()
        let lentaFlow = LentaFlow(
            viewController: lentaVC,
            notificationsViewModel: notificationsViewModel
        )

        let employeesViewController = configuredStuff()
        let employeesFlow = EmployeesFlow(
            viewController: employeesViewController
        )

        let menuVC = configuredMenu()
        let menuFlow = MenuFlow(
            viewController: menuVC,
            topQuestionsViewModel: topQuestionsViewModel,
            notificationsViewModel: notificationsViewModel
        )

        if let nav1 = biOfficeFlow.root as? UIViewController,
            let nav2 = biBoardFlow.root as? UIViewController,
            let nav3 = lentaFlow.root as? UIViewController,
            let vc4 = employeesFlow.root as? UIViewController,
            let nav5 = menuFlow.root as? UIViewController {
            viewController.viewControllers = [nav1, nav2, nav3, vc4, nav5]
        }

        var flowItems = [NextFlowItem]()

        flowItems.append(
            NextFlowItem(nextPresentable: biOfficeFlow,
                         nextStepper: OneStepper(withSingleStep: AppStep.biOffice))
        )
        flowItems.append(
            NextFlowItem(nextPresentable: biBoardFlow,
                         nextStepper: OneStepper(withSingleStep: AppStep.biBoard))
        )
        flowItems.append(
            NextFlowItem(nextPresentable: lentaFlow,
                         nextStepper: OneStepper(withSingleStep: AppStep.lenta))
        )
        flowItems.append(
            NextFlowItem(nextPresentable: employeesFlow,
                         nextStepper: OneStepper(withSingleStep: AppStep.employees))
        )
        flowItems.append(
            NextFlowItem(nextPresentable: menuFlow,
                         nextStepper: OneStepper(withSingleStep: AppStep.menu))
        )

        return NextFlowItems.multiple(flowItems: flowItems)
    }
    //swiftlint:enable function_body_length

    // MARK: - Methods

    private func configuredBIOffice() -> BIOfficeViewController {
        let biOfficeViewModel = BIOfficeViewModel(
            tasksAndRequestsViewModel: tasksAndRequestsViewModel
        )
        let biOfficeVC = BIOfficeViewController(
            viewModel: biOfficeViewModel
        )
        return biOfficeVC
    }

    private func configuredBIBoard() -> BIBoardViewController {
        let biBoardViewModel = BIBoardViewModel(
            stuffViewModel: stuffViewModel,
            topQuestionsViewModel: topQuestionsViewModel
        )

        let biBoardVC = BIBoardViewController(viewModel: biBoardViewModel)
        return biBoardVC
    }

    private func configuredLenta() -> LentaViewController {
        let lentaVC = LentaViewController()
        return lentaVC
    }

    private func configuredStuff() -> StuffViewController {
        let stuffVC = StuffViewController(stuffViewModel: stuffViewModel)
        return stuffVC
    }

    private func configuredMenu() -> MenuViewController {
        let menuVC = MenuViewController.instantiate(withViewModel: MenuViewModel())
        return menuVC
    }

}
