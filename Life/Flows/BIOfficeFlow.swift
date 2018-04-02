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

    private let rootViewController: BIOfficeViewController

    private unowned var notificationsViewModel: NotificationsViewModel
    private unowned var tasksAndRequestsViewModel: TasksAndRequestsViewModel
    private unowned var employeesViewModel: EmployeesViewModel

    init(viewController: BIOfficeViewController,
         notificationsViewModel: NotificationsViewModel,
         tasksAndRequestsViewModel: TasksAndRequestsViewModel,
         employeesViewModel: EmployeesViewModel) {
        rootViewController = viewController

        self.notificationsViewModel = notificationsViewModel
        self.tasksAndRequestsViewModel = tasksAndRequestsViewModel
        self.employeesViewModel = employeesViewModel
    }

    func navigate(to step: Step) -> NextFlowItems {
        guard let step = step as? AppStep else { return NextFlowItems.stepNotHandled }

        switch step {
        case .biOffice:
            return NextFlowItems.one(
                flowItem: NextFlowItem(
                    nextPresentable: rootViewController,
                    nextStepper: rootViewController
                )
            )
        case .newsPicked(let id):
            return navigationToNewsDetail(id)
        case .newsDone:
            return navigationFromNewsDetail()
        case .tasksAndRequests:
            return navigationToTasksAndRequests()
        case .createRequest(let category, let didCreateRequest):
            return navigationToRequestForm(category: category, didCreateRequest: didCreateRequest)
        case .createRequestDone:
            return navigationFromRequestForm()
        case .createTask(let didCreateTask):
            return navigationToTaskForm(didCreateTask: didCreateTask)
        case .createTaskDone:
            return navigationFromTaskForm()
        case .suggestionPicked(let id):
            return navigationToSuggestion(id)
        case .suggestionDone:
            return navigationFromSuggestion()
        case .createSuggestion(let completion):
            return navigationToSuggestionForm(completion: completion)
        case .createSuggestionDone:
            return navigationFromSuggestionForm()
        default:
            return NextFlowItems.stepNotHandled
        }
    }

    private func navigationToNewsDetail(_ id: String) -> NextFlowItems {
        let viewController = NewsViewController(
            viewModel: NewsItemViewModel(id: id)
        )
        self.rootViewController.present(viewController, animated: true, completion: nil)
        return NextFlowItems.one(flowItem:
            NextFlowItem(
                nextPresentable: viewController,
                nextStepper: viewController)
        )
    }

    private func navigationFromNewsDetail() -> NextFlowItems {
        self.rootViewController.presentedViewController?.dismiss(animated: true, completion: nil)
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

    private func navigationToTaskForm(didCreateTask: @escaping (() -> Void)) -> NextFlowItems {
        let viewModel = TaskFormViewModel(employeesViewModel: employeesViewModel)
        let vc = TaskFormViewController(viewModel: viewModel)
        vc.didCreateTask = didCreateTask
        self.rootViewController.present(vc, animated: true, completion: nil)
        return NextFlowItems.one(flowItem: NextFlowItem(nextPresentable: vc, nextStepper: vc))
    }

    private func navigationFromTaskForm() -> NextFlowItems {
        self.rootViewController.presentedViewController?.dismiss(animated: true, completion: nil)
        return NextFlowItems.none
    }

    private func navigationToSuggestion( _ id: String) -> NextFlowItems {
        let viewController = SuggestionViewController(
            viewModel: SuggestionItemViewModel(id: id)
        )
        self.rootViewController.present(viewController, animated: true, completion: nil)
        return NextFlowItems.one(flowItem:
            NextFlowItem(
                nextPresentable: viewController,
                nextStepper: viewController)
        )
    }

    private func navigationFromSuggestion() -> NextFlowItems {
        self.rootViewController.presentedViewController?.dismiss(animated: true, completion: nil)
        return NextFlowItems.none
    }

    private func navigationToSuggestionForm(
        completion: @escaping ((Suggestion, ImageSize) -> Void)) -> NextFlowItems {
        let vc = SuggestionFormViewController()
        vc.didAddSuggestion = completion
        self.rootViewController.present(vc, animated: true, completion: nil)
        return NextFlowItems.one(flowItem: NextFlowItem(nextPresentable: vc, nextStepper: vc))
    }

    private func navigationFromSuggestionForm() -> NextFlowItems {
        self.rootViewController.presentedViewController?.dismiss(animated: true, completion: nil)
        return NextFlowItems.none
    }

}
