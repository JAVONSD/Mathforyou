//
//  UIView+Extensions.swift
//  Life
//
//  Created by Shyngys Kassymov on 12.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit

extension UIView {
    func setAllConstraintsPriority(to priority: UILayoutPriority) {
        for constraint in constraints {
            constraint.priority = priority
        }
    }
}
