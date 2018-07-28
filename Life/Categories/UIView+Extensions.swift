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

    func setView(disabled: Bool, decreaseOpacity: Bool = false) {
        isUserInteractionEnabled = !disabled

        if disabled {
            alpha = decreaseOpacity ? 0.5 : 1
        } else {
            alpha = 1
        }
    }

    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }

    func getHeightConstraint() -> NSLayoutConstraint? {
        var heightConstraint: NSLayoutConstraint?
        for constraint in constraints where constraint.firstAttribute == .height {
            heightConstraint = constraint
        }
        return heightConstraint
    }

}










