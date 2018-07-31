//
//  UserProfileFlow.swift
//  Life
//
//  Created by 123 on 31.07.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit

// all the navigation code, such as presenting or pushing view controllers, is declared in Flows.

class UserProfileFlow: Flow {
    
    var root: Presentable {
        return self.rootViewController
    }
    
    private var rootViewController: UserProfileViewController
    
    init(viewController: UserProfileViewController) {
        rootViewController = viewController
    }
    
    func navigate(to step: Step) -> NextFlowItems {
        guard let step = step as? AppStep else { return NextFlowItems.stepNotHandled }
        
        switch step {
        case .userProfile:
            return NextFlowItems.none
        default:
            return NextFlowItems.stepNotHandled
        }
    }
    
}
