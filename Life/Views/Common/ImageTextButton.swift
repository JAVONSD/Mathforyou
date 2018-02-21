//
//  ImageTextButton.swift
//  Life
//
//  Created by Shyngys Kassymov on 12.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material
import SnapKit

class ImageTextButton: UIView {

    private(set) var view: ImageTextView?
    private(set) var button: FlatButton?

    var didTap: (() -> Void)?

    init(image: UIImage? = nil,
         title: String? = nil,
         subtitle: String? = nil) {
        super.init(frame: .zero)

        setContentCompressionResistancePriority(.required, for: .vertical)
        setContentHuggingPriority(.defaultLow, for: .vertical)

        setupView(image: image, title: title, subtitle: subtitle)
        setupButton()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Actions

    @objc
    private func onButtonTap() {
        if let didTap = didTap {
            didTap()
        }
    }

    // MARK: - UI

    private func setupView(image: UIImage? = nil,
                           title: String? = nil,
                           subtitle: String? = nil) {
        view = ImageTextView(image: image, title: title, subtitle: subtitle)
        view?.isUserInteractionEnabled = false

        guard let view = view else { return }

        addSubview(view)
        view.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }
            make.edges.equalTo(self)
        }
    }

    private func setupButton() {
        button = FlatButton(title: nil)
        button?.addTarget(self, action: #selector(onButtonTap), for: .touchUpInside)

        button?.setContentCompressionResistancePriority(.required, for: .vertical)
        button?.setContentHuggingPriority(.defaultLow, for: .vertical)

        guard let button = button else { return }

        addSubview(button)
        button.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }
            make.edges.equalTo(self)
        }
    }

}
