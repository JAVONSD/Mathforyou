//
//  UIViewController+Extensions.swift
//  Life
//
//  Created by Shyngys Kassymov on 15.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Toast

enum ToastPosition {
    case bottom, center, top
}

extension UIViewController {

    // MARK: - Toast

    func showToast(_ message: String, position: ToastPosition = .bottom) {
        var toastPosition = CSToastPositionBottom
        if position == .center {
            toastPosition = CSToastPositionCenter
        } else if position == .top {
            toastPosition = CSToastPositionTop
        }

        view.makeToast(message, duration: 2.0, position: toastPosition)
    }

}
