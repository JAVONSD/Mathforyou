//
//  Button.swift
//  Life
//
//  Created by Shyngys Kassymov on 11.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material
import SnapKit

class Button: RaisedButton {

    override init(title: String?, titleColor: UIColor = .white) {
        super.init(title: title, titleColor: titleColor)

        pulseColor = .white
        backgroundColor = App.Color.azure

        layer.cornerRadius = 14
        titleLabel?.font = App.Font.button

        snp.makeConstraints { (make) in
            make.height.equalTo(App.Layout.buttonHeight)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
