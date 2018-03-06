//
//  BIOfficeFlow.swift
//  Life
//
//  Created by Shyngys Kassymov on 14.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit

class BIOfficeFlow: Flow {

    var root: Presentable {
        return self.rootViewController
    }

    private var rootViewController: AppToolbarController
    private var viewController: BIOfficeViewController

    private unowned var notificationsViewModel: NotificationsViewModel
    private unowned var tasksAndRequestsViewModel: TasksAndRequestsViewModel
    private unowned var employeesViewModel: EmployeesViewModel

    init(viewController: BIOfficeViewController,
         notificationsViewModel: NotificationsViewModel,
         tasksAndRequestsViewModel: TasksAndRequestsViewModel,
         employeesViewModel: EmployeesViewModel) {
        self.viewController = viewController
        rootViewController = AppToolbarController(rootViewController: viewController)

        self.notificationsViewModel = notificationsViewModel
        self.tasksAndRequestsViewModel = tasksAndRequestsViewModel
        self.employeesViewModel = employeesViewModel

        rootViewController.setupToolbarButtons(for: viewController)
        rootViewController.didTapNotifications = { [weak self] in
            self?.viewController.step.accept(AppStep.notifications)
        }
        rootViewController.didTapProfile = { [weak self] in
            self?.viewController.step.accept(AppStep.profile)
        }
    }

    func navigate(to step: Step) -> NextFlowItems {
        guard let step = step as? AppStep else { return NextFlowItems.stepNotHandled }

        switch step {
        case .biOffice:
            return NextFlowItems.one(
                flowItem: NextFlowItem(
                    nextPresentable: viewController,
                    nextStepper: viewController
                )
            )
        case .profile:
            return navigationToProfileScreen()
        case .notifications:
            return navigationToNotifications()
        case .notificationsDone:
            return navigationFromNotifications()
        case .tasksAndRequests:
            return navigationToTasksAndRequests()
        case .createRequest(let category, let didCreateRequest):
            return navigationToRequestForm(category: category, didCreateRequest: didCreateRequest)
        case .createRequestDone:
            return navigationFromRequestForm()
        default:
            return NextFlowItems.stepNotHandled
        }
    }

    private func navigationToProfileScreen() -> NextFlowItems {
        let viewController = ProfileViewController.configuredVC
        let flow = ProfileFlow(viewController: viewController)
        self.rootViewController.pushViewController(viewController, animated: true)
        return NextFlowItems.one(flowItem:
            NextFlowItem(
                nextPresentable: flow,
                nextStepper: viewController)
        )
    }

    private func navigationToNotifications() -> NextFlowItems {
        let notificationsViewController = NotificationsViewController.instantiate(
            withViewModel: notificationsViewModel
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
        let tasksAndRequestsFlow = TasksAndRequestsFlow(
            viewModel: tasksAndRequestsViewModel,
            employeesViewModel: employeesViewModel
        )
        Flows.whenReady(
            flow1: tasksAndRequestsFlow, block: { [weak self] (root: TasksAndRequestsFABController) in
            self?.rootViewController.present(root, animated: true)
        })
        return NextFlowItems.one(flowItem: NextFlowItem(
            nextPresentable: tasksAndRequestsFlow,
            nextStepper: tasksAndRequestsViewModel
        ))
    }

    private func navigationToRequestForm(
        category: Request.Category, didCreateRequest: @escaping (() -> Void)) -> NextFlowItems {
        let viewModel = RequestFormViewModel(category: category)
        let vc = RequestFormViewController(viewModel: viewModel)
        vc.didCreateRequest = didCreateRequest
        self.rootViewController.present(vc, animated: true, completion: nil)
        return NextFlowItems.one(flowItem: NextFlowItem(nextPresentable: vc, nextStepper: vc))
    }

    private func navigationFromRequestForm() -> NextFlowItems {
        self.rootViewController.presentedViewController?.dismiss(animated: true, completion: nil)
        return NextFlowItems.none
    }

}
