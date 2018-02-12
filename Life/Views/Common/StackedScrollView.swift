//
//  StackedScrollView.swift
//  Life
//
//  Created by Shyngys Kassymov on 12.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import SnapKit

class StackedScrollView: UIScrollView {

    private(set) var stackView: UIStackView?

    enum ScrollDirection {
        case vertical, horizontal
    }

    private(set) var scrollDirection = ScrollDirection.vertical

    init(direction: ScrollDirection) {
        super.init(frame: .zero)

        scrollDirection = direction

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard let stackView = stackView else { return }

        var size = stackView.frame.size
        if scrollDirection == .vertical {
            size.width = frame.size.width
        } else {
            size.height = frame.size.height
        }
        contentSize = size
    }

    // MARK: - UI

    private func setupUI() {
        stackView = UIStackView()

        guard let stackView = stackView else { return }

        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.axis = scrollDirection == .vertical ? .vertical : .horizontal
        addSubview(stackView)
        stackView.snp.makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }

            if scrollDirection == .vertical {
                make.top.equalTo(self)
                make.left.equalTo(self)
                make.right.equalTo(self)
                make.width.equalTo(self)
            } else {
                make.top.equalTo(self)
                make.left.equalTo(self)
                make.bottom.equalTo(self)
                make.height.equalTo(self)
            }
        }

        setAllConstraintsPriority(to: UILayoutPriority(rawValue: 999))
    }

}
