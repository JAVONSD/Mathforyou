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

    private var rootViewController = AppToolbarController(
        rootViewController: BIOfficeViewController.instantiate(
            withViewModel: BIOfficeViewModel()
        )
    )

    func navigate(to step: Step) -> NextFlowItems {
        guard let step = step as? AppStep else { return NextFlowItems.stepNotHandled }

        switch step {
        case .biOffice:
            rootViewController.tabItem.image = #imageLiteral(resourceName: "office-inactive")
            return NextFlowItems.none
        default:
            return NextFlowItems.stepNotHandled
        }
    }

}
