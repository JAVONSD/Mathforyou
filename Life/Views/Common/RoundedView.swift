//
//  RoundedView.swift
//  Life
//
//  Created by Shyngys Kassymov on 20.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit

class RoundedView: UIView {

    var cornerRadius: CGFloat = App.Layout.cornerRadius
    var corners: UIRectCorner = .allCorners

    override init(frame: CGRect) {
        super.init(frame: frame)

        roundCorners(corners, radius: cornerRadius)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        roundCorners(corners, radius: cornerRadius)
    }

}
