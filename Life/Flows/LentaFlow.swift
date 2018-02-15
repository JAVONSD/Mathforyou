//
//  LentaFlow.swift
//  Life
//
//  Created by Shyngys Kassymov on 14.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit

class LentaFlow: Flow {

    var root: Presentable {
        return self.rootViewController
    }

    private var rootViewController = AppToolbarController(
        rootViewController: LentaViewController.instantiate(
            withViewModel: LentaViewModel()
        )
    )

    func navigate(to step: Step) -> NextFlowItems {
        guard let step = step as? AppStep else { return NextFlowItems.stepNotHandled }

        switch step {
        case .lenta:
            rootViewController.tabItem.image = #imageLiteral(resourceName: "feed-office-inactive")
            return NextFlowItems.none
        default:
            return NextFlowItems.stepNotHandled
        }
    }

}
