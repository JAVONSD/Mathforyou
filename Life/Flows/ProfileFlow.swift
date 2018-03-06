//
//  ProfileFlow.swift
//  Life
//
//  Created by Shyngys Kassymov on 14.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit

class ProfileFlow: Flow {

    var root: Presentable {
        return self.rootViewController
    }

    private var rootViewController: ProfileViewController

    init(viewController: ProfileViewController) {
        rootViewController = viewController
    }

    func navigate(to step: Step) -> NextFlowItems {
        guard let step = step as? AppStep else { return NextFlowItems.stepNotHandled }

        switch step {
        case .profile:
            return NextFlowItems.none
        default:
            return NextFlowItems.stepNotHandled
        }
    }

}
