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

    private var rootViewController = AppToolbarController(
        rootViewController: EmployeesViewController.instantiate(
            withViewModel: EmployeesViewModel()
        )
    )

    func navigate(to step: Step) -> NextFlowItems {
        guard let step = step as? AppStep else { return NextFlowItems.stepNotHandled }

        switch step {
        case .employees:
            rootViewController.tabItem.image = #imageLiteral(resourceName: "stuff-inactive")
            return NextFlowItems.none
        default:
            return NextFlowItems.stepNotHandled
        }
    }

}
