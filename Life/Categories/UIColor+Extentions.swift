//
//  UIColor+Extentions.swift
//  Life
//
//  Created by 123 on 30.07.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
}
