//
//  Button.swift
//  Life
//
//  Created by Shyngys Kassymov on 11.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material
import NVActivityIndicatorView
import SnapKit

class Button: RaisedButton {

    public enum ButtonState {
        case normal, loading, disabled
    }

    var buttonState = ButtonState.normal {
        didSet {
            switch buttonState {
            case .normal:
                makeButtonNormal()
            case .loading:
                startToAnimate()
            case .disabled:
                makeButtonDisabled()
            }
        }
    }

    private var savedTitle: String?

    private(set) lazy var activityView = NVActivityIndicatorView(
        frame: CGRect.init(x: 0, y: 0, width: 30, height: 30),
        type: .ballPulse,
        color: UIColor.white,
        padding: 0
    )

    override init(title: String?, titleColor: UIColor = .white) {
        super.init(title: title, titleColor: titleColor)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI

    private func setupUI() {
        pulseColor = .white
        backgroundColor = App.Color.azure

        shadowColor = App.Color.black12
        depth = Depth(offset: Offset.init(horizontal: 0, vertical: 8), opacity: 1, radius: 12)

        layer.cornerRadius = App.Layout.cornerRadius
        titleLabel?.font = App.Font.button

        snp.makeConstraints { (make) in
            make.height.equalTo(App.Layout.buttonHeight)
        }

        setupActivityView()
    }

    private func setupActivityView() {
        activityView.isHidden = true
        addSubview(activityView)
        activityView.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }
            make.size.equalTo(activityView.frame.size)
            make.center.equalTo(self)
        }
    }

    // MARK: - Methods

    private func makeButtonNormal() {
        stopToAnimate()
        setView(disabled: false)
    }

    private func startToAnimate() {
        isUserInteractionEnabled = false

        savedTitle = title(for: .normal)
        setTitle(nil, for: .normal)

        activityView.isHidden = false
        activityView.startAnimating()
    }

    private func stopToAnimate() {
        setTitle(savedTitle, for: .normal)

        activityView.stopAnimating()
        activityView.isHidden = true

        isUserInteractionEnabled = true
    }

    private func makeButtonDisabled() {
        stopToAnimate()
        setView(disabled: true)
    }

}
