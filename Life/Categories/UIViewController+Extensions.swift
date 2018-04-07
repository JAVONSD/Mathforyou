//
//  UIViewController+Extensions.swift
//  Life
//
//  Created by Shyngys Kassymov on 15.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Kingfisher
import Material
import MBProgressHUD
import NVActivityIndicatorView
import RxSwift
import RxCocoa
import Toast

enum ToastPosition {
    case bottom, center, top
}

extension UIViewController {

    // MARK: - Alert

    func showErrorAlert(_ message: String) {
        let alert = UIAlertController(
            title: NSLocalizedString("error", comment: ""),
            message: message,
            preferredStyle: .alert
        )
        alert.popoverPresentationController?.sourceView = view
        let cancelAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }

    // MARK: - HUD

    func showHUD(title: String?) {
        let spinner = NVActivityIndicatorView(
            frame: .init(x: 0, y: 0, width: 60, height: 60),
            type: .circleStrokeSpin,
            color: UIColor.white,
            padding: App.Layout.itemSpacingSmall
        )
        spinner.startAnimating()

        if let app = UIApplication.shared.delegate as? AppDelegate, let window = app.window {
            let hud = MBProgressHUD.showAdded(to: window, animated: true)
            hud.bezelView.color = UIColor.black.withAlphaComponent(0.75)
            hud.backgroundView.blurEffectStyle = .dark
            hud.backgroundView.color = UIColor.black.withAlphaComponent(0.5)
            hud.animationType = .zoomIn
            hud.mode = .customView
            hud.removeFromSuperViewOnHide = true
            hud.label.text = title
            hud.contentColor = .white
            hud.customView = spinner
        }
    }

    func hideHUD() {
        if let app = UIApplication.shared.delegate as? AppDelegate, let window = app.window {
            MBProgressHUD.hide(for: window, animated: true)
        }
    }

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
