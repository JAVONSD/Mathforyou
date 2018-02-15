//
//  SizedButton.swift
//  Life
//
//  Created by Shyngys Kassymov on 15.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material
import SnapKit

class SizedButton: IconButton {

    private(set) lazy var iconView = UIImageView()
    private var size: CGSize

    init(image: UIImage?, size: CGSize) {
        self.size = size

        super.init(frame: .init(origin: .zero, size: size))

        setupUI(image: image)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI

    private func setupUI(image: UIImage?) {
        iconView.contentMode = .scaleAspectFit
        iconView.image = image
        addSubview(iconView)
        iconView.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }
            make.center.equalTo(self)
            make.size.equalTo(self.size)
        }
    }

}
