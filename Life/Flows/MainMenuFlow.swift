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

    private var tasksAndRequestsViewModel = TasksAndRequestsViewModel.sample()

    private var employeesViewModel = EmployeesViewModel.sample()
    private var birthdaysViewModel = BirthdaysViewModel.sample()
    private var vacanciesViewModel = VacanciesViewModel.sample()

    var root: Presentable {
        return self.rootViewController
    }

    private let rootViewController: AppToolbarController
    private let tabBarController: AppTabBarController

    init(tabBarController: AppTabBarController) {
        self.tabBarController = tabBarController
        self.rootViewController = AppToolbarController(rootViewController: self.tabBarController)
    }

    //swiftlint:disable cyclomatic_complexity
    func navigate(to step: Step) -> NextFlowItems {
        guard let step = step as? AppStep else { return NextFlowItems.stepNotHandled }

        switch step {
        case .login:
            return navigationToLoginScreen()
        case .mainMenu:
            return navigationToMainMenuScreen()
        case .profile:
            return navigationToProfileScreen()
        case .notifications:
            return navigationToNotifications()
        case .notificationsDone:
            return navigationFromNotifications()
        case .tasksAndRequests:
            return navigationToTasksAndRequests()
        case .tasksAndRequestsDone:
            return navigationFromTasksAndRequests()
        case .employeePicked(let code):
            return navigationToEmployee(code)
        case .employeeDone:
            return navigationFromEmployee()
        case .topQuestions:
            return navigationToTopQuestions()
        default:
            return NextFlowItems.stepNotHandled
        }
    }
    //swiftlint:enable cyclomatic_complexity

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
        let biBoardVC = BIBoardViewController()
        biBoardVC.onUnathorizedError = {
            self.navigateToLoginScreen(isUnathorized: true)
        }

        let biOfficeVC = BIOfficeViewController()
        var biOfficeViewModel = BIOfficeViewModel()
        biOfficeViewModel.tasksAndRequestsViewModel = tasksAndRequestsViewModel
        biOfficeVC.viewModel = biOfficeViewModel
        biOfficeVC.onUnathorizedError = {
            self.navigateToLoginScreen(isUnathorized: true)
        }

        let lentaVC = LentaViewController()
        lentaVC.onUnathorizedError = {
            self.navigateToLoginScreen(isUnathorized: true)
        }

        let stuffVC = StuffViewController(
            employeesViewModel: employeesViewModel,
            birthdaysViewModel: birthdaysViewModel,
            vacanciesViewModel: vacanciesViewModel
        )
        stuffVC.didSelectEmployee = { code in
            self.rootViewController.step.accept(AppStep.employeePicked(withId: code))
        }
        stuffVC.didSelectBirthdate = { code in
            self.rootViewController.step.accept(AppStep.employeePicked(withId: code))
        }
        stuffVC.didSelectVacancy = { code in

        }
        stuffVC.onUnathorizedError = {
            self.navigateToLoginScreen(isUnathorized: true)
        }

        let menuVC = MenuViewController.instantiate(withViewModel: MenuViewModel())
        menuVC.topQuestionTapped = {
            self.rootViewController.step.accept(AppStep.topQuestions)
        }
        menuVC.onUnathorizedError = {
            self.navigateToLoginScreen(isUnathorized: true)
        }

        tabBarController.viewControllers = [
            biOfficeVC,
            biBoardVC,
            lentaVC,
            stuffVC,
            menuVC
        ]

        return NextFlowItems.one(flowItem: NextFlowItem(
            nextPresentable: rootViewController,
            nextStepper: rootViewController
        ))
    }

    private func navigationToProfileScreen() -> NextFlowItems {
        let viewController = ProfileViewController.configuredVC
        self.rootViewController.pushViewController(viewController, animated: true)
        return NextFlowItems.none
    }

    private func navigationToNotifications() -> NextFlowItems {
        let notificationsViewController = NotificationsViewController.instantiate(
            withViewModel: NotificationsViewModel()
        )
        self.rootViewController.present(notificationsViewController, animated: true, completion: nil)
        return NextFlowItems.one(flowItem:
            NextFlowItem(
                nextPresentable: notificationsViewController,
                nextStepper: notificationsViewController)
        )
    }

    private func navigationFromNotifications() -> NextFlowItems {
        self.rootViewController.visibleViewController?.dismiss(animated: true, completion: nil)
        return NextFlowItems.none
    }

    private func navigationToTasksAndRequests() -> NextFlowItems {
        let tasksAndRequestsViewController = TasksAndRequestsViewController.instantiate(
            withViewModel: tasksAndRequestsViewModel
        )
        let fabController = TasksAndRequestsFABController(
            rootViewController: tasksAndRequestsViewController
        )
        self.rootViewController.present(fabController, animated: true, completion: nil)
        return NextFlowItems.one(flowItem:
            NextFlowItem(
                nextPresentable: tasksAndRequestsViewController,
                nextStepper: tasksAndRequestsViewController)
        )
    }

    private func navigationFromTasksAndRequests() -> NextFlowItems {
        self.rootViewController.visibleViewController?.dismiss(animated: true, completion: nil)
        return NextFlowItems.none
    }

    private func navigationToEmployee(_ code: String) -> NextFlowItems {
        guard let viewModel = (employeesViewModel.employees.filter {
            $0.employee.code == code }).first else {
            return NextFlowItems.none
        }
        let notificationsViewController = EmployeeViewController.instantiate(
            withViewModel: viewModel
        )
        self.rootViewController.present(notificationsViewController, animated: true, completion: nil)
        return NextFlowItems.one(flowItem:
            NextFlowItem(
                nextPresentable: notificationsViewController,
                nextStepper: notificationsViewController)
        )
    }

    private func navigationFromEmployee() -> NextFlowItems {
        self.rootViewController.visibleViewController?.dismiss(animated: true, completion: nil)
        return NextFlowItems.none
    }

    private func navigationToTopQuestions() -> NextFlowItems {
        let viewController = TopQuestionsViewController(viewModel: TopQuestionsViewModel.sample())
        rootViewController.pushViewController(viewController, animated: true)
        return NextFlowItems.none
    }

}
