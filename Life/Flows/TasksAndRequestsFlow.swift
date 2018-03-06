//
//  TasksAndRequestsFlow.swift
//  Life
//
//  Created by Shyngys Kassymov on 05.03.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit

class TasksAndRequestsFlow: Flow {

    var root: Presentable {
        return self.rootViewController
    }

    private var rootViewController: TasksAndRequestsFABController

    private unowned var viewModel: TasksAndRequestsViewModel
    private unowned var employeesViewModel: EmployeesViewModel

    init(viewModel: TasksAndRequestsViewModel, employeesViewModel: EmployeesViewModel) {
        self.viewModel = viewModel
        self.employeesViewModel = employeesViewModel
        let viewController = TasksAndRequestsViewController(viewModel: viewModel)
        rootViewController = TasksAndRequestsFABController(rootViewController: viewController)
        rootViewController.didTapAddButton = { [weak self] (category, didCreateRequest) in
            self?.viewModel.createNewRequest(category: category, didCreateRequest: didCreateRequest)
        }
        rootViewController.didTapAddTaskButton = { [weak self] didCreateTask in
            self?.viewModel.createNewTask(didCreateTask: didCreateTask)
        }
    }

    func navigate(to step: Step) -> NextFlowItems {
        guard let step = step as? AppStep else { return NextFlowItems.stepNotHandled }

        switch step {
        case .tasksAndRequestsDone:
            return navigationFromTasksAndRequests()
        case .createRequest(let category, let didCreateRequest):
            return navigationToRequestForm(category: category, didCreateRequest: didCreateRequest)
        case .createRequestDone:
            return navigationFromRequestForm()
        case .createTask(let didCreateTask):
            return navigationToTaskForm(didCreateTask: didCreateTask)
        case .createTaskDone:
            return navigationFromTaskForm()
        default:
            return NextFlowItems.stepNotHandled
        }
    }

    private func navigationFromTasksAndRequests() -> NextFlowItems {
        self.rootViewController.dismiss(animated: true, completion: nil)
        return NextFlowItems.none
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

}
