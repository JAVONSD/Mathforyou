//
//  TextField.swift
//  Life
//
//  Created by Shyngys Kassymov on 11.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material

class TextField: ErrorTextField {

    override init(frame: CGRect) {
        super.init(frame: .zero)

        dividerColor = App.Color.coolGrey
        dividerActiveColor = App.Color.azure

        placeholderNormalColor = App.Color.blackDisable
        placeholderActiveColor = App.Color.azure

        font = App.Font.subheadAlts
        placeholderLabel.font = App.Font.subhead

        placeholderVerticalOffset = 16

        textColor = .black
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
