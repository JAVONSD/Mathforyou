//
//  RoundedNode.swift
//  Life
//
//  Created by Shyngys Kassymov on 20.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class RoundedNode: ASDisplayNode {

    var radius = App.Layout.cornerRadius
    var corners: UIRectCorner = .allCorners

    override func layout() {
        super.layout()

        roundCorners(corners, radius: radius)
    }

    private func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }

}
