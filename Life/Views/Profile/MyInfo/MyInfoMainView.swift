//
//  MyInfoMainView.swift
//  Life
//
//  Created by Shyngys Kassymov on 12.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Material
import SnapKit

class MyInfoMainView: StackedView {

    private(set) var infoView: ImageTextView?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupInfoView()
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI

    private func setupInfoView() {
        infoView = ImageTextView(image: nil, title: "Фамилия\nИмя", subtitle: "Должность")
        infoView?.imageSize = CGSize(width: 96, height: 96)
        infoView?.imageView?.backgroundColor = .clear

        guard let stackView = stackView, let infoView = infoView else { return }

        infoView.textStackView?.insets = UIEdgeInsets(top: App.Layout.itemSpacingSmall,
                                                                        left: 0,
                                                                        bottom: App.Layout.itemSpacingSmall,
                                                                        right: 0)
        infoView.textStackView?.stackView?.spacing = App.Layout.itemSpacingMedium
        infoView.textStackView?.stackView?.distribution = .equalCentering

        stackView.addArrangedSubview(infoView)
    }

}
