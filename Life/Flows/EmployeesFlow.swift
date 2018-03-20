//
//  EmployeesFlow.swift
//  Life
//
//  Created by Shyngys Kassymov on 14.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit

class EmployeesFlow: Flow {

    var root: Presentable {
        return self.rootViewController
    }

    private var rootViewController: StuffViewController

    init(viewController: StuffViewController) {
        rootViewController = viewController
    }

    func navigate(to step: Step) -> NextFlowItems {
        guard let step = step as? AppStep else { return NextFlowItems.stepNotHandled }

        switch step {
        case .employees:
            return NextFlowItems.one(
                flowItem: NextFlowItem(
                    nextPresentable: rootViewController,
                    nextStepper: rootViewController
                )
            )
        case .employeePicked(let employee):
            return navigationToEmployee(employee)
        case .employeeDone:
            return navigationFromEmployee()
        default:
            return NextFlowItems.stepNotHandled
        }
    }

    private func navigationToEmployee(_ employee: Employee) -> NextFlowItems {
        let employeeViewController = EmployeeViewController.instantiate(
            withViewModel: EmployeeViewModel(employee: employee)
        )
        let navigationController = UINavigationController(rootViewController: employeeViewController)
        navigationController.setNavigationBarHidden(true, animated: false)
        self.rootViewController.present(navigationController, animated: true, completion: nil)
        return NextFlowItems.one(flowItem:
            NextFlowItem(
                nextPresentable: navigationController,
                nextStepper: employeeViewController)
        )
    }

    private func navigationFromEmployee() -> NextFlowItems {
        self.rootViewController.presentedViewController?.dismiss(animated: true, completion: nil)
        return NextFlowItems.none
    }

}
